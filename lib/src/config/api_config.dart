class ApiConfig {
  static const String baseUrl = "http://10.0.2.2:3001/";

  // Auth endpoints
  static const String login = "/auth/login";
  static const String signup = "/auth/signup";
  static const String checkVerification = "/auth/check-verification/{email}";
  static const String logout = "/auth/logout";

  // User endpoints
  static const String getProfile = "/users/me";

  // Admin endpoints
  static const String getAllUsers = "/admin/users";

  // Chat endpoints
  static const String chatAI = "/chat-ai";
}
