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
import '../../../../core/localization/context_extension.dart';
import '../../../../core/localization/logic/locale_cubit.dart';

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
        title: Text(context.l10n.myProfile),
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
                        label: context.l10n.firstName,
                        value: user.firstName,
                      ),
                      ProfileInfoItem(
                        icon: Icons.person_outline,
                        label: context.l10n.lastName,
                        value: user.lastName,
                      ),
                      ProfileInfoItem(
                        icon: Icons.email_outlined,
                        label: context.l10n.email,
                        value: user.email,
                      ),
                      ProfileInfoItem(
                        icon: Icons.phone_outlined,
                        label: context.l10n.phone,
                        value: user.phone,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(Icons.language, color: Theme.of(context).primaryColor),
                      title: Text(context.l10n.language),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showLanguagePicker(context),
                    ),
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
                    label: Text(context.l10n.editProfile),
                  ),
                ],
              ),
            );
          }
          return Center(child: Text(context.l10n.noProfileData));
        },
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  context.l10n.selectLanguage,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(context.l10n.english),
                onTap: () {
                  context.read<LocaleCubit>().changeLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(context.l10n.arabic),
                onTap: () {
                  context.read<LocaleCubit>().changeLocale(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(context.l10n.russian),
                onTap: () {
                  context.read<LocaleCubit>().changeLocale(const Locale('ru'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
