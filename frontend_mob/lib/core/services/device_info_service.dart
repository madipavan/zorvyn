import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin;
  DeviceInfoService(this._deviceInfoPlugin);
  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfoPlugin.androidInfo;
        return info.id;
      } else if (Platform.isIOS) {
        final info = await _deviceInfoPlugin.iosInfo;
        return info.identifierForVendor ?? 'unknown';
      }
      return 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }
}
