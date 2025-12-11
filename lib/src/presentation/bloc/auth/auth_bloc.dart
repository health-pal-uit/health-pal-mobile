import 'package:da1/src/data/repositories/auth_repository.dart';
import 'package:da1/src/presentation/bloc/auth/auth_event.dart';
import 'package:da1/src/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());

      final result = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      result.fold(
        (failure) {
          emit(AuthFailure(failure.message));
        },
        (user) {
          emit(Authenticated(user));
        },
      );
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());

      final result = await authRepository.signUp(
        username: event.username,
        password: event.password,
        email: event.email,
      );

      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(Unauthenticated()),
      );
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await authRepository.logout();
      emit(Unauthenticated());
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());

      final result = await authRepository.loginWithGoogle();

      result.fold(
        (failure) {
          if (failure.message == 'GOOGLE_AUTH_PENDING') {
            emit(Unauthenticated());
          } else {
            emit(AuthFailure(failure.message));
          }
        },
        (user) {
          emit(Authenticated(user));
        },
      );
    });

    on<GoogleSignInSuccess>((event, emit) {
      emit(Authenticated(event.user));
    });

    on<GoogleSignInFailed>((event, emit) {
      emit(AuthFailure(event.error));
    });

    on<LoadCurrentUser>((event, emit) async {
      final result = await authRepository.getCurrentUser();
      
      result.fold(
        (failure) {
          emit(AuthFailure(failure.message));
        },
        (user) {
          emit(Authenticated(user));
        },
      );
    });

    on<CheckVerificationStatus>((event, emit) async {
      final result = await authRepository.checkVerification(event.email);

      result.fold((failure) {}, (isVerified) async {
        if (isVerified) {
          emit(VerificationSuccess());
        }
      });
    });
  }
}
