import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<void> initDeepLinks({
    required Function(String token) onTokenReceived,
    required Function(String error) onError,
    Function(Uri uri)? onPasswordResetLink,
  }) async {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri, onTokenReceived, onError, onPasswordResetLink);
      },
      onError: (error) {
        onError(error.toString());
      },
    );

    // Handle deep link when app is launched from a cold start
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(
          initialUri,
          onTokenReceived,
          onError,
          onPasswordResetLink,
        );
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  void _handleDeepLink(
    Uri uri,
    Function(String token) onTokenReceived,
    Function(String error) onError,
    Function(Uri uri)? onPasswordResetLink,
  ) {
    // Check if this is the OAuth callback
    if (uri.scheme == 'da1' && uri.host == 'login-callback') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        onTokenReceived(token);
      } else {
        onError('No token received from Google');
      }
    }
    // Check if this is the password reset link
    else if (uri.scheme == 'da1' && uri.host == 'reset-callback') {
      if (onPasswordResetLink != null) {
        onPasswordResetLink(uri);
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
