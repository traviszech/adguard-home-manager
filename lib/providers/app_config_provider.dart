import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfigProvider with ChangeNotifier {
  PackageInfo? _appInfo;
  AndroidDeviceInfo? _androidDeviceInfo;
  IosDeviceInfo? _iosDeviceInfo;

  PackageInfo? get getAppInfo {
    return _appInfo;
  }

  AndroidDeviceInfo? get androidDeviceInfo {
    return _androidDeviceInfo;
  }

  IosDeviceInfo? get iosDeviceInfo {
    return _iosDeviceInfo;
  }

  void setAppInfo(PackageInfo appInfo) {
    _appInfo = appInfo;
  }

  void setAndroidInfo(AndroidDeviceInfo deviceInfo) {
    _androidDeviceInfo = deviceInfo;
  }

  void setIosInfo(IosDeviceInfo deviceInfo) {
    _iosDeviceInfo = deviceInfo;
  }
}