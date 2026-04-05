import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object> get props => [];
}

class UpdateAvatarRequested extends UserEvent {
  final String imagePath;

  const UpdateAvatarRequested(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}
