import 'package:da1/src/data/repositories/user_repository.dart';
import 'package:da1/src/presentation/bloc/user/user_event.dart';
import 'package:da1/src/presentation/bloc/user/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<UpdateAvatarRequested>((event, emit) async {
      emit(UserLoading());

      final result = await userRepository.updateAvatar(event.imagePath);

      result.fold(
        (failure) {
          emit(UserFailure(failure.message));
        },
        (user) {
          emit(UserAvatarUpdated(user));
        },
      );
    });
  }
}
