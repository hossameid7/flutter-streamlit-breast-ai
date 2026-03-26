import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repo/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit(this._authRepo) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _authRepo.login(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (userCredential) => emit(AuthAuthenticated()),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    emit(AuthLoading());
    final result = await _authRepo.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (userCredential) => emit(AuthAuthenticated()),
    );
  }

  Future<void> logout() async {
    await _authRepo.logout();
    emit(AuthUnauthenticated());
  }

  void checkAuth() {
    final user = _authRepo.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
