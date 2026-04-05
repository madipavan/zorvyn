import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_mob/core/network/dio_client.dart';
import 'package:frontend_mob/core/router/app_router.dart';
import 'package:frontend_mob/core/theme/theme_cubit.dart';
import 'package:frontend_mob/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend_mob/features/auth/data/repo/auth_repository_impl.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => FlutterSecureStorage(),
  );
  getIt.registerSingleton<DioClient>(DioClient(getIt<FlutterSecureStorage>()));
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      AuthRepositoryImpl(
        AuthRemoteDatasource(getIt<DioClient>(), getIt<FlutterSecureStorage>()),
      ),
    ),
  );
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  getIt.registerLazySingleton<AppRouter>(
    () => AppRouter(getIt<FlutterSecureStorage>()),
  );
}
