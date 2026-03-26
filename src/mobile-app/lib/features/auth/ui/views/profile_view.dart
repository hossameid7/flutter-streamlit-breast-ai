import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../logic/auth_cubit.dart';
import '../../logic/profile_cubit.dart';
import '../../logic/profile_state.dart';
import '../../../../core/routes/routes.dart';
import '../../data/repo/auth_repo.dart';
import '../../../../core/di/service_locator.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_error_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = sl<AuthRepo>().getCurrentUser();
    if (user != null) {
      context.read<ProfileCubit>().getProfile(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.login,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return ProfileErrorView(
              message: state.message,
              onRetry: _loadProfile,
            );
          } else if (state is ProfileLoaded) {
            final user = state.user;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                  ProfileHeader(
                    firstName: user.firstName,
                    lastName: user.lastName,
                  ),
                  SizedBox(height: 30.h),
                  ProfileInfoCard(
                    items: [
                      ProfileInfoItem(
                        icon: Icons.person_outline,
                        label: 'First Name',
                        value: user.firstName,
                      ),
                      ProfileInfoItem(
                        icon: Icons.person_outline,
                        label: 'Last Name',
                        value: user.lastName,
                      ),
                      ProfileInfoItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      ProfileInfoItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.phone,
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.editProfile,
                        arguments: user,
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profile'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No profile data available'));
        },
      ),
    );
  }
}
