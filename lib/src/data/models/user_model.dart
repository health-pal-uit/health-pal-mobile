import 'package:da1/src/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.username,
    required super.email,
    super.fullName,
    super.phone,
    super.gender,
    super.birthDate,
    super.avatarUrl,
    super.isVerified,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullname'],
      phone: json['phone'],
      gender: json['gender'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      avatarUrl: json['avatar_url'],
      isVerified: json['isVerified'],
      role: json['role']?['name'],
    );
  }

  User toEntity() => User(
        id: id,
        username: username,
        email: email,
        fullName: fullName,
        phone: phone,
        gender: gender,
        birthDate: birthDate,
        avatarUrl: avatarUrl,
        isVerified: isVerified,
        role: role,
      );
}

class LoginResponseModel {
  final String accessToken;

  LoginResponseModel({required this.accessToken});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(accessToken: json['data']['token']);
  }
}
