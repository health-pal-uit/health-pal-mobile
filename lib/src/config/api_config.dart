import 'package:da1/src/config/env.dart';

class ApiConfig {
  // Base URL
  static final String baseUrl = Env.backendApiUrl;

  // Auth endpoints
  static const String login = "/auth/login";
  static const String signup = "/auth/signup";
  static const String checkVerification = "/auth/check-verification/{email}";
  static const String logout = "/auth/logout";

  // User endpoints
  static const String getProfile = "/users/me";
  static const String updateProfile = "/users/me";

  // Admin endpoints
  static const String getAllUsers = "/admin/users";

  // Chat endpoints
  static const String chatAI = "/chat-ai";

  // Post endpoints
  static const String getPosts = "/posts";
  static const String createPost = "/posts";
  static String getUserPosts(String userId) => "/posts/user/$userId";
  static String reportPost(String postId) => "/posts/report/$postId";
  static String likePost(String postId) => "/posts/$postId/like";
  static String unlikePost(String postId) => "/posts/$postId/unlike";
  static String getComments(String postId) => "/posts/$postId/comments";
  static String addComment(String postId) => "/posts/$postId/comments";

  // Device endpoints
  static const String registerDevice = "/users/me/device";

  // Fitness Profile endpoints
  static const String calculateBodyFat = "/fitness-profiles/calculate-bfp";
}
