import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String username;
  final String password;
  final String email;

  const SignUpRequested({
    required this.username,
    required this.password,
    required this.email,
  });

  @override
  List<Object> get props => [username, password, email];
}

class SignOutRequested extends AuthEvent {}

class CheckVerificationStatus extends AuthEvent {
  final String email;

  const CheckVerificationStatus(this.email);

  @override
  List<Object> get props => [email];
}
