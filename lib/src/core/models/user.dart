import 'package:equatable/equatable.dart';

enum UserRole { user, expert, pendingExpert }

class User extends Equatable {
  final String id;
  final String? username;
  final String email;
  final String? fullName;
  final String? phone;
  final bool? gender;
  final DateTime? birthDate;
  final String? avatarUrl;
  final bool? isVerified;
  final UserRole? role;

  const User({
    required this.id,
    this.username,
    required this.email,
    this.fullName,
    this.phone,
    this.gender,
    this.birthDate,
    this.avatarUrl,
    this.isVerified,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String roleString = 'user';
    if (json['role'] != null) {
      if (json['role'] is Map<String, dynamic> &&
          json['role']['name'] != null) {
        roleString = json['role']['name'];
      } else if (json['role'] is String) {
        roleString = json['role'];
      }
    }

    UserRole parsedRole = UserRole.user;
    if (roleString == 'expert') parsedRole = UserRole.expert;
    if (roleString == 'pending_expert' || roleString == 'pendingExpert') {
      parsedRole = UserRole.pendingExpert;
    }

    return User(
      id: json['id'] as String,
      username: json['username'] as String?,
      email: json['email'] as String,
      fullName: json['fullname'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as bool?,
      birthDate:
          json['birth_date'] != null
              ? DateTime.parse(json['birth_date'] as String)
              : null,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['isVerified'] as bool?,
      role: parsedRole,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    fullName,
    phone,
    gender,
    birthDate,
    avatarUrl,
    isVerified,
    role,
  ];
}

class LoginResponseModel {
  final String accessToken;

  LoginResponseModel({required this.accessToken});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(accessToken: json['data']['token']);
  }
}
