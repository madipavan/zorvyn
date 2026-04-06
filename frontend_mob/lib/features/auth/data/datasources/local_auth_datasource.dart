import 'package:local_auth/local_auth.dart';

abstract class LocalAuthDataSource {
  Future<bool> authenticate();
  Future<bool> isDeviceSupported();
}

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final LocalAuthentication localAuth;

  LocalAuthDataSourceImpl(this.localAuth);

  @override
  Future<bool> isDeviceSupported() async {
    return await localAuth.isDeviceSupported() &&
        await localAuth.canCheckBiometrics;
  }

  @override
  Future<bool> authenticate() async {
    try {
      return await localAuth.authenticate(
        localizedReason: 'Authenticate to unlock',
        biometricOnly: false,
      );
    } catch (_) {
      return false;
    }
  }
}
