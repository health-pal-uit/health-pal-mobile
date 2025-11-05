import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? fullName;

  const User({required this.id, required this.email, this.fullName});

  @override
  List<Object?> get props => [id, email, fullName];
}

class LoginResponseModel {
  final String accessToken;

  LoginResponseModel({required this.accessToken});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(accessToken: json['data']['token']);
  }
}
