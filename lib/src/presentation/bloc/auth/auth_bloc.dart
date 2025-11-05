import 'package:da1/src/data/repositories/auth_repository.dart';
import 'package:da1/src/presentation/bloc/auth/auth_event.dart';
import 'package:da1/src/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository; // Inject repository vào

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading()); // Báo cho UI biết là đang loading

      final result = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      // Dùng .fold() của Dartz (Either)
      result.fold(
        (failure) {
          // Nếu Left(Failure)
          emit(AuthFailure(failure.message));
        },
        (user) {
          // Nếu Right(User)
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
        phone: event.phone,
        fullname: event.fullname,
        gender: event.gender,
        birthday: event.birthday,
      );

      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(Unauthenticated()),
      );
    });

    // Xử lý sự kiện Đăng xuất
    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await authRepository.logout();
      emit(Unauthenticated()); // Chuyển về trạng thái chưa đăng nhập
    });

    on<CheckVerificationStatus>((event, emit) async {
      // BLoC không cần emit Loading, vì đây là polling chạy nền
      // Trừ khi người dùng nhấn nút "Kiểm tra" thủ công

      final result = await authRepository.checkVerification(event.email);

      result.fold((failure) {}, (isVerified) {
        if (isVerified) {
          emit(Unauthenticated());
        } else {}
      });
    });
  }
}
