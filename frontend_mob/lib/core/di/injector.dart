import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_mob/core/network/dio_client.dart';
import 'package:frontend_mob/core/router/app_router.dart';
import 'package:frontend_mob/core/services/device_info_service.dart';
import 'package:frontend_mob/core/theme/theme_cubit.dart';
import 'package:frontend_mob/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend_mob/features/auth/data/datasources/local_auth_datasource.dart';
import 'package:frontend_mob/features/auth/data/datasources/local_auth_storage_data_source.dart';
import 'package:frontend_mob/features/auth/data/repo/auth_repository_impl.dart';
import 'package:frontend_mob/features/auth/presentation/cubit/local_auth_cubit.dart';
import 'package:frontend_mob/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:frontend_mob/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:frontend_mob/features/dashboard/domain/repositories/i_dashboard_repository.dart';
import 'package:frontend_mob/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:frontend_mob/features/goals/data/datasources/goal_remote_datasource.dart';
import 'package:frontend_mob/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:frontend_mob/features/goals/domain/repositories/i_goal_repository.dart';
import 'package:frontend_mob/features/goals/presentation/bloc/goal_bloc.dart';
import 'package:frontend_mob/features/insights/data/datasources/insights_remote_datasource.dart';
import 'package:frontend_mob/features/insights/data/repositories/insights_repository_impl.dart';
import 'package:frontend_mob/features/insights/domain/repositories/i_insights_repository.dart';
import 'package:frontend_mob/features/insights/presentation/bloc/insights_bloc.dart';
import 'package:frontend_mob/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:frontend_mob/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:frontend_mob/features/transactions/domain/repositories/i_transaction_repository.dart';
import 'package:frontend_mob/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';

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
  getIt.registerLazySingleton(() => LocalAuthentication());
  //AUTH
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      AuthRepositoryImpl(
        AuthRemoteDatasource(getIt<DioClient>(), getIt<FlutterSecureStorage>()),
        DeviceInfoService(getIt<DeviceInfoPlugin>()),
        LocalAuthDataSourceImpl(getIt()),
        LocalAuthStorageDataSourceImpl(getIt()),
      ),
    ),
  );
  getIt.registerLazySingleton<LocalAuthDataSource>(
    () => LocalAuthDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<LocalAuthStorageDataSource>(
    () => LocalAuthStorageDataSourceImpl(getIt()),
  );
  getIt.registerFactory(() => LocalAuthCubit(authRepository: getIt()));
  //DASHBOARD
  getIt.registerLazySingleton<IDashboardRemoteDatasource>(
    () => DashboardRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<IDashboardRepository>(
    () => DashboardRepositoryImpl(getIt()),
  );
  getIt.registerFactory<DashboardBloc>(() => DashboardBloc(getIt()));
  //TXN
  getIt.registerLazySingleton<ITransactionRemoteDatasource>(
    () => TransactionRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<ITransactionRepository>(
    () => TransactionRepositoryImpl(getIt()),
  );
  getIt.registerFactory<TransactionBloc>(() => TransactionBloc(getIt()));

  //goal
  getIt.registerLazySingleton<IGoalRemoteDatasource>(
    () => GoalRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<IGoalRepository>(
    () => GoalRepositoryImpl(getIt()),
  );
  getIt.registerFactory<GoalBloc>(() => GoalBloc(getIt()));

  //Insights
  getIt.registerLazySingleton<IInsightsRemoteDatasource>(
    () => InsightsRemoteDatasource(getIt()),
  );
  getIt.registerLazySingleton<IInsightsRepository>(
    () => InsightsRepositoryImpl(getIt()),
  );
  getIt.registerFactory<InsightsBloc>(() => InsightsBloc(getIt()));
}
