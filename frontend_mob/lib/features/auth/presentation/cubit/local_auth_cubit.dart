import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/features/auth/domain/repositories/i_auth_repository.dart';

import 'local_auth_state.dart';

class LocalAuthCubit extends Cubit<LocalAuthState> {
  final IAuthRepository authRepository;
  LocalAuthCubit({required this.authRepository}) : super(LocalAuthInitial());

  Future<void> checkAndAuthenticate() async {
    emit(LocalAuthLoading());

    try {
      final supported = await authRepository.isDeviceSupported();
      final success = await authRepository.authenticate();
      if (!supported) {
        emit(LocalAuthUnlocked());
      }
      if (success) {
        emit(LocalAuthUnlocked());
      } else {
        emit(LocalAuthLocked());
      }
    } catch (e) {
      emit(LocalAuthUnlocked());
    }
  }

  Future<void> toggleBiometric(bool value) async {
    await authRepository.setBiometricEnabled(value);
  }
}
