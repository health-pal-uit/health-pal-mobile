import 'package:da1/src/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.id, required super.email, super.fullName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
    );
  }

  User toEntity() => User(id: id, email: email, fullName: fullName);
}

class LoginResponseModel {
  final String accessToken;

  LoginResponseModel({required this.accessToken});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(accessToken: json['data']['token']);
  }
}
