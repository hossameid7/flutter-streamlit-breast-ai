import 'package:breast_app/core/routes/app_router.dart';
import 'package:breast_app/core/routes/routes.dart';
import 'package:breast_app/core/navigation/navigation_service.dart';
import 'package:breast_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:breast_app/core/di/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:breast_app/features/auth/logic/auth_cubit.dart';
import 'package:breast_app/features/auth/logic/profile_cubit.dart';
import 'package:breast_app/features/breast_scan/logic/breast_scan_cubit.dart';
import 'package:breast_app/core/theme/app_theme.dart';

import 'package:breast_app/features/auth/data/repo/auth_repo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl<AuthCubit>()),
            BlocProvider(create: (context) => sl<ProfileCubit>()),
            BlocProvider(create: (context) => sl<BreastScanCubit>()),
          ],

          child: MaterialApp(
            title: 'Breast App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeData,
            navigatorKey: sl<NavigationService>().navigatorKey,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: sl<AuthRepo>().getCurrentUser() != null
                ? Routes.breastScan
                : Routes.login,
          ),
        );
      },
    );
  }
}
