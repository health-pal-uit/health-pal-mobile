import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Send forgot password email using Supabase
  /// The email will contain a reset link with format: redirectTo?token=xxx
  static Future<void> forgotPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: "da1://reset-callback/",
    );
  }

  /// Sign up user with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  /// Sign in user with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out current user
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Reset password with new password
  /// This should be called after user follows the reset link
  static Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Verify if user's email is confirmed
  static Future<bool> isEmailVerified() async {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  /// Get current authenticated user
  static User? get currentUser => _supabase.auth.currentUser;

  /// Get current session
  static Session? get currentSession => _supabase.auth.currentSession;

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
}
