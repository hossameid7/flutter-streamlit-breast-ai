import 'package:get_it/get_it.dart';
import '../../features/auth/data/data_source/auth_remote_data_source.dart';
import '../../features/auth/data/repo/auth_repo.dart';
import '../../features/auth/data/repo/profile_repo.dart';
import '../../features/auth/logic/auth_cubit.dart';
import '../../features/auth/logic/profile_cubit.dart';
import '../../features/breast_scan/data/repo/breast_scan_repo.dart';
import '../../features/breast_scan/data/services/breast_detection_service.dart';
import '../../features/breast_scan/data/services/breast_segmentation_service.dart';
import '../../features/breast_scan/logic/breast_scan_cubit.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../localization/locale_service.dart';
import '../localization/logic/locale_cubit.dart';

import '../navigation/navigation_service.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Localization
  sl.registerLazySingleton(() => LocaleService(sl()));
  sl.registerLazySingleton(() => LocaleCubit(sl()));

  // Navigation
  sl.registerLazySingleton(() => NavigationService());

  // Data Source
  sl.registerLazySingleton(() => AuthRemoteDataSource());

  // Repositories
  sl.registerLazySingleton(() => AuthRepo(sl()));
  sl.registerLazySingleton(() => ProfileRepo(sl()));

  // Cubits
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerFactory(() => ProfileCubit(sl()));
  sl.registerFactory(() => BreastScanCubit(sl()));

  // Breast Scan Services & Repo
  sl.registerLazySingleton(() => BreastDetectionService());
  sl.registerLazySingleton(() => BreastSegmentationService());
  sl.registerLazySingleton(
    () => BreastScanRepo(detectionService: sl(), segmentationService: sl()),
  );
}
