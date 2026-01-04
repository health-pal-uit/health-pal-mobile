import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:da1/src/data/repositories/device_repository.dart';

class DeviceRegistrationService {
  final DeviceRepository deviceRepository;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  DeviceRegistrationService({required this.deviceRepository});

  /// Register device with push token
  Future<void> registerDevice() async {
    try {
      // Request notification permission
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

      // Register device with backend
      final result = await deviceRepository.registerDevice(
        deviceId: deviceId,
        pushToken: token,
      );

      result.fold((failure) {}, (_) {});

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {});
    } catch (e) {
      // Handle registration error
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

  /// Set up foreground message handler
  void setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
  }

  /// Set up background message handler
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {}
}
