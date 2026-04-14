import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/routes.dart';
import '../../logic/auth_cubit.dart';
import '../../logic/auth_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/login_form.dart';
import '../widgets/account_redirection_row.dart';
import '../../../../core/localization/context_extension.dart';
import '../../../../core/localization/logic/locale_cubit.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => _showLanguagePicker(context),
              icon: Icon(Icons.language, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is AuthAuthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.breastScan,
                (route) => false,
              );
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  Colors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AuthHeader(
                      title: context.l10n.welcomeBack,
                      subtitle: context.l10n.signInSubtitle,
                    ),
                    SizedBox(height: 48.h),
                    const LoginForm(),
                    SizedBox(height: 24.h),
                    AccountRedirectionRow(
                      text: context.l10n.dontHaveAccount,
                      actionText: context.l10n.register,
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.register,
                        (route) => false,
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.l10n.selectLanguage,
                  style: const TextStyle(
                    fontSize: 18,
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
