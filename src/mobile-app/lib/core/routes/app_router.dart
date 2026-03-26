import 'package:flutter/material.dart';
import 'package:breast_app/features/auth/ui/views/login_view.dart';
import 'package:breast_app/features/auth/ui/views/register_view.dart';
import 'package:breast_app/features/auth/ui/views/profile_view.dart';
import 'package:breast_app/features/auth/ui/views/edit_profile_view.dart';
import 'package:breast_app/features/breast_scan/ui/views/breast_scan_view.dart';
import 'package:breast_app/core/models/user_model.dart';

import 'routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileView());
      case Routes.editProfile:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => EditProfileView(user: user));
      case Routes.home:
      case Routes.breastScan:
        return MaterialPageRoute(builder: (_) => const BreastScanView());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
