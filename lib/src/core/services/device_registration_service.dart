import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:da1/src/data/repositories/device_repository.dart';
import 'package:da1/src/core/services/local_notification_service.dart';

class DeviceRegistrationService {
  final DeviceRepository deviceRepository;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  DeviceRegistrationService({required this.deviceRepository});

  /// Register device with push token
  Future<void> registerDevice() async {
    try {
      final NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        return;
      }

      // Get FCM token
      final String? token = await _firebaseMessaging.getToken();
      if (token == null) {
        return;
      }

      // Get device ID
      final String deviceId = await _getDeviceId();

      final result = await deviceRepository.registerDevice(
        deviceId: deviceId,
        pushToken: token,
      );

      result.fold((failure) {}, (_) {});

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _refreshToken(deviceId, newToken);
      });
    } catch (e) {
      //handle error
    }
  }

  /// Get unique device identifier
  Future<String> _getDeviceId() async {
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.id; // Android device ID
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown-ios-device';
    }
    return 'unknown-device';
  }

  /// Refresh token when FCM token changes
  Future<void> _refreshToken(String deviceId, String newToken) async {
    try {
      final result = await deviceRepository.registerDevice(
        deviceId: deviceId,
        pushToken: newToken,
      );

      result.fold((failure) {}, (_) {});
    } catch (e) {
      //handle error
    }
  }

  /// Set up foreground message handler
  void setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Display notification when app is in foreground
      if (message.notification != null) {
        _localNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          payload: message.data['post_id']?.toString(),
          priority: NotificationPriority.high,
        );
      }
    });
  }

  /// Set up background message handler
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    // Display notification when app is in background
    if (message.notification != null) {
      await LocalNotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        payload: message.data['post_id']?.toString(),
        priority: NotificationPriority.high,
      );
    }
  }

  /// Set up notification tap handler
  void setupNotificationTapHandler(Function(String?) onNotificationTap) {
    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final postId = message.data['post_id']?.toString();
      onNotificationTap(postId);
    });
  }

  /// Get initial message if app was opened from terminated state
  Future<void> handleInitialMessage(Function(String?) onNotificationTap) async {
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      final postId = initialMessage.data['post_id']?.toString();
      onNotificationTap(postId);
    }
  }
}
