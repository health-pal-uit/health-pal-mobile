import 'package:da1/src/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserAvatarUpdated extends UserState {
  final User user;
  const UserAvatarUpdated(this.user);
  @override
  List<Object> get props => [user];
}

class UserFailure extends UserState {
  final String message;
  const UserFailure(this.message);
  @override
  List<Object> get props => [message];
}
