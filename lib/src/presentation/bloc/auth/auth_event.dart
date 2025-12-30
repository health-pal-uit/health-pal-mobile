import 'package:equatable/equatable.dart';
import 'package:da1/src/domain/entities/user.dart';

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

class GoogleSignInRequested extends AuthEvent {}

class GoogleSignInSuccess extends AuthEvent {
  final User user;
  const GoogleSignInSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class GoogleSignInFailed extends AuthEvent {
  final String error;
  const GoogleSignInFailed(this.error);

  @override
  List<Object> get props => [error];
}

class LoadCurrentUser extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class CheckVerificationStatus extends AuthEvent {
  final String email;

  const CheckVerificationStatus(this.email);

  @override
  List<Object> get props => [email];
}
