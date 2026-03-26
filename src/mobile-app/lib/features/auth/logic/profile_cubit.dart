import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repo/profile_repo.dart';
import 'profile_state.dart';
import '../../../../core/models/user_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo;

  ProfileCubit(this._profileRepo) : super(ProfileInitial());

  Future<void> getProfile(String uid) async {
    emit(ProfileLoading());
    final result = await _profileRepo.getUserProfile(uid);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> updateProfile(UserModel user) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(user));
      final result = await _profileRepo.updateProfile(user);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (_) => emit(ProfileLoaded(user)),
      );
    }
  }
}
