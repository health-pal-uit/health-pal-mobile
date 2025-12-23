class PostModel {
  final String id;
  final String content;
  final String attachType;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final UserInfo user;
  final int likeCount;

  PostModel({
    required this.id,
    required this.content,
    required this.attachType,
    required this.isApproved,
    required this.createdAt,
    this.deletedAt,
    required this.user,
    this.likeCount = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      content: json['content'] as String,
      attachType: json['attach_type'] as String,
      isApproved: json['is_approved'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'attach_type': attachType,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'user': user.toJson(),
      'like_count': likeCount,
    };
  }

  // Helper method để tính thời gian từ khi post
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  // Helper method để lấy hashtags từ content hoặc attachType
  List<String> getHashtags() {
    final hashtags = <String>[];

    // Thêm hashtag dựa trên attach_type
    if (attachType == 'meal') {
      hashtags.add('#Nutrition');
      hashtags.add('#MealPrep');
    } else if (attachType == 'challenge') {
      hashtags.add('#Challenge');
      hashtags.add('#Fitness');
    } else if (attachType == 'medal') {
      hashtags.add('#Achievement');
      hashtags.add('#Milestone');
    } else if (attachType == 'ingredient') {
      hashtags.add('#HealthyEating');
      hashtags.add('#Nutrition');
    }

    return hashtags;
  }
}

class UserInfo {
  final String id;
  final String username;
  final String? email;
  final String? phone;
  final String? fullname;
  final bool? gender;
  final String? birthDate;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? deactivatedAt;
  final bool? isVerified;

  UserInfo({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.fullname,
    this.gender,
    this.birthDate,
    this.avatarUrl,
    required this.createdAt,
    this.deactivatedAt,
    this.isVerified,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullname: json['fullname'] as String?,
      gender: json['gender'] as bool?,
      birthDate: json['birth_date'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      deactivatedAt:
          json['deactivated_at'] != null
              ? DateTime.parse(json['deactivated_at'] as String)
              : null,
      isVerified: json['isVerified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'fullname': fullname,
      'gender': gender,
      'birth_date': birthDate,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'deactivated_at': deactivatedAt?.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  // Helper để lấy display name
  String getDisplayName() {
    return fullname ?? username;
  }

  // Helper để lấy avatar URL hoặc placeholder
  String getAvatarUrl() {
    return avatarUrl ?? 'https://i.pravatar.cc/150?u=$id';
  }
}

class PostsResponse {
  final List<PostModel> data;
  final String message;
  final int statusCode;

  PostsResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    return PostsResponse(
      data:
          (json['data'] as List)
              .map((post) => PostModel.fromJson(post as Map<String, dynamic>))
              .toList(),
      message: json['message'] as String,
      statusCode: json['statusCode'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((post) => post.toJson()).toList(),
      'message': message,
      'statusCode': statusCode,
    };
  }
}
