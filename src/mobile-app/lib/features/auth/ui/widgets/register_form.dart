import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../logic/auth_cubit.dart';
import '../../logic/auth_state.dart';
import '../../../../core/localization/context_extension.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.firstName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: context.l10n.lastName),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: context.l10n.email,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        SizedBox(height: 20.h),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: context.l10n.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
        SizedBox(height: 20.h),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: context.l10n.password,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 40.h),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state is AuthLoading
                  ? null
                  : () {
                      context.read<AuthCubit>().register(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        phone: _phoneController.text.trim(),
                      );
                    },
              child: state is AuthLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(context.l10n.createAccount),
            );
          },
        ),
      ],
    );
  }
}
