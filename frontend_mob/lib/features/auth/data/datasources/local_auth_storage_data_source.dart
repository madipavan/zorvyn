import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class LocalAuthStorageDataSource {
  Future<void> setBiometricEnabled(bool value);
  Future<bool> isBiometricEnabled();
}

class LocalAuthStorageDataSourceImpl implements LocalAuthStorageDataSource {
  final FlutterSecureStorage storage;

  static const _key = "biometric_enabled";

  LocalAuthStorageDataSourceImpl(this.storage);

  @override
  Future<void> setBiometricEnabled(bool value) async {
    await storage.write(key: _key, value: value.toString());
  }

  @override
  Future<bool> isBiometricEnabled() async {
    // final value = await storage.read(key: _key);
    return true;
  }
}
