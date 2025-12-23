import 'package:da1/src/config/utils/date_time_helper.dart';
import 'package:da1/src/data/models/post_model.dart';

class CommentModel {
  final String id;
  final String content;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final UserInfo user;

  CommentModel({
    required this.id,
    required this.content,
    required this.isApproved,
    required this.createdAt,
    this.deletedAt,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      content: json['content'] as String,
      isApproved: json['is_approved'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'user': user.toJson(),
    };
  }

  String getTimeAgo() {
    return DateTimeHelper.getTimeAgo(createdAt);
  }
}

class CommentsResponse {
  final List<CommentModel> data;
  final String message;
  final int statusCode;

  CommentsResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    return CommentsResponse(
      data:
          (json['data'] as List<dynamic>)
              .map(
                (item) => CommentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      message: json['message'] as String,
      statusCode: json['statusCode'] as int,
    );
  }
}
