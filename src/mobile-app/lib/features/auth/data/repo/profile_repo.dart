import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/user_model.dart';
import '../data_source/auth_remote_data_source.dart';

class ProfileRepo {
  final AuthRemoteDataSource _remoteDataSource;

  ProfileRepo(this._remoteDataSource);

  Future<Either<Failure, UserModel>> getUserProfile(String uid) async {
    try {
      final data = await _remoteDataSource.getUserData(uid);
      if (data != null) {
        return Right(UserModel.fromFirestore(data, uid));
      } else {
        return Left(ServerFailure('User not found'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateProfile(UserModel user) async {
    try {
      await _remoteDataSource.updateUserData(user.uid, user.toFirestore());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
