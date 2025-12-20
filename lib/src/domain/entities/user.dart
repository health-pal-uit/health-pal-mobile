import 'package:equatable/equatable.dart';

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
  final String? role;

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
