class Expert {
  final String id;
  final String bio;
  final int tokenPerMinute;
  final String licenseId;
  final String? licenseUrl;
  final bool isVerified;
  final double ratingAvg;
  final int ratingCount;
  final String userId;
  final String username;
  final String? fullname;
  final String? avatarUrl;
  final String roleName;
  final bool canDoVideo;

  Expert({
    required this.id,
    required this.bio,
    required this.tokenPerMinute,
    required this.licenseId,
    this.licenseUrl,
    required this.isVerified,
    required this.ratingAvg,
    required this.ratingCount,
    required this.userId,
    required this.username,
    this.fullname,
    this.avatarUrl,
    required this.roleName,
    required this.canDoVideo,
  });

  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      id: json['id'] ?? '',
      bio: json['bio'] ?? '',
      tokenPerMinute: json['token_per_minute'] ?? 0,
      licenseId: json['license_id'] ?? '',
      licenseUrl: json['license_url'],
      isVerified: json['is_verified'] ?? false,
      ratingAvg: (json['rating_avg'] ?? 0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      userId: json['user']?['id'] ?? '',
      username: json['user']?['username'] ?? '',
      fullname: json['user']?['fullname'],
      avatarUrl: json['user']?['avatar_url'],
      roleName: json['expert_role']?['name'] ?? '',
      canDoVideo: json['expert_role']?['can_do_video'] ?? false,
    );
  }
}
