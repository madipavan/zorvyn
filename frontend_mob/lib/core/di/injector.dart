import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_mob/core/network/dio_client.dart';
import 'package:frontend_mob/core/router/app_router.dart';
import 'package:frontend_mob/core/services/device_info_service.dart';
import 'package:frontend_mob/core/theme/theme_cubit.dart';
import 'package:frontend_mob/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend_mob/features/auth/data/repo/auth_repository_impl.dart';
import 'package:frontend_mob/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:frontend_mob/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:frontend_mob/features/dashboard/domain/repositories/i_dashboard_repository.dart';
import 'package:frontend_mob/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:frontend_mob/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:frontend_mob/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:frontend_mob/features/transactions/domain/repositories/i_transaction_repository.dart';
import 'package:frontend_mob/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  //DEPENDENCY
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => FlutterSecureStorage(),
  );
  getIt.registerSingleton<DeviceInfoPlugin>(DeviceInfoPlugin());
  getIt.registerSingleton<DioClient>(DioClient(getIt<FlutterSecureStorage>()));
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  getIt.registerLazySingleton<AppRouter>(
    () => AppRouter(getIt<FlutterSecureStorage>()),
  );
  //AUTH
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      AuthRepositoryImpl(
        AuthRemoteDatasource(getIt<DioClient>(), getIt<FlutterSecureStorage>()),
        DeviceInfoService(getIt<DeviceInfoPlugin>()),
      ),
    ),
  );
  //TXN
  getIt.registerLazySingleton<ITransactionRemoteDatasource>(
    () => TransactionRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<ITransactionRepository>(
    () => TransactionRepositoryImpl(getIt()),
  );
  getIt.registerFactory<TransactionBloc>(() => TransactionBloc(getIt()));

  //DASHBOARD
  getIt.registerLazySingleton<IDashboardRemoteDatasource>(
    () => DashboardRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<IDashboardRepository>(
    () => DashboardRepositoryImpl(getIt()),
  );
  getIt.registerFactory<DashboardBloc>(() => DashboardBloc(getIt()));
}
