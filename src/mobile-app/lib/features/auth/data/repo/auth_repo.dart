import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../data_source/auth_remote_data_source.dart';

class AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepo(this._remoteDataSource);

  Future<Either<Failure, UserCredential>> login(
    String email,
    String password,
  ) async {
    try {
      final result = await _remoteDataSource.loginWithEmailAndPassword(
        email,
        password,
      );
      return Right(result);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, UserCredential>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final result = await _remoteDataSource.registerWithEmailAndPassword(
        email,
        password,
        firstName,
        lastName,
        phone,
      );
      return Right(result);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Registration failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  User? getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }
}
