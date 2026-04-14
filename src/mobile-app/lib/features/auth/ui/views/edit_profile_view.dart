import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../logic/profile_cubit.dart';
import '../../logic/profile_state.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/context_extension.dart';

class EditProfileView extends StatefulWidget {
  final UserModel user;
  const EditProfileView({super.key, required this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editProfile), elevation: 0),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && state is! ProfileUpdating) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.profileUpdatedSuccess)),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(context.l10n.personalInformation),
              SizedBox(height: 20.h),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.firstName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.lastName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: context.l10n.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              SizedBox(height: 40.h),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  final isLoading = state is ProfileUpdating;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final updatedUser = UserModel(
                              uid: widget.user.uid,
                              email: widget.user.email,
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              phone: _phoneController.text.trim(),
                              photoURL: widget.user.photoURL,
                            );
                            context.read<ProfileCubit>().updateProfile(
                              updatedUser,
                            );
                          },
                    child: isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(context.l10n.saveChanges),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.pinkColor,
        letterSpacing: 1,
      ),
    );
  }
}
