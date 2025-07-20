import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MobileFeaturesService {
  static final MobileFeaturesService _instance = MobileFeaturesService._internal();
  factory MobileFeaturesService() => _instance;
  MobileFeaturesService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();

  // Biometric Authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return isAvailable && canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      debugPrint('Error during biometric authentication: $e');
      return false;
    }
  }

  // Device Information
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      return {
        'platform': 'Android',
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'brand': androidInfo.brand,
        'device': androidInfo.device,
        'androidVersion': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
        'appVersion': packageInfo.version,
        'appBuildNumber': packageInfo.buildNumber,
        'packageName': packageInfo.packageName,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
      };
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return {};
    }
  }

  // Connectivity
  Future<ConnectivityResult> getConnectivityStatus() async {
    try {
      final List<ConnectivityResult> connectivityResult = 
          await _connectivity.checkConnectivity();
      return connectivityResult.isNotEmpty 
          ? connectivityResult.first 
          : ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return ConnectivityResult.none;
    }
  }

  Stream<List<ConnectivityResult>> get connectivityStream => 
      _connectivity.onConnectivityChanged;

  bool isOnline(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  // Local Storage
  Future<bool> saveSecureData(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
      debugPrint('Error saving secure data: $e');
      return false;
    }
  }

  Future<String?> getSecureData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      debugPrint('Error getting secure data: $e');
      return null;
    }
  }

  Future<bool> removeSecureData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      debugPrint('Error removing secure data: $e');
      return false;
    }
  }

  // App Settings
  Future<bool> setBiometricEnabled(bool enabled) async {
    return await saveSecureData('biometric_enabled', enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await getSecureData('biometric_enabled');
    return value == 'true';
  }

  Future<bool> setOfflineModeEnabled(bool enabled) async {
    return await saveSecureData('offline_mode_enabled', enabled.toString());
  }

  Future<bool> isOfflineModeEnabled() async {
    final value = await getSecureData('offline_mode_enabled');
    return value == 'true';
  }

  // Notification Settings
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await saveSecureData('notifications_enabled', enabled.toString());
  }

  Future<bool> isNotificationsEnabled() async {
    final value = await getSecureData('notifications_enabled');
    return value != 'false'; // Default to true if not set
  }

  // Haptic Feedback
  void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  void selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  // System UI
  void setSystemUIOverlayStyle({
    Color? statusBarColor,
    Brightness? statusBarIconBrightness,
    Color? systemNavigationBarColor,
    Brightness? systemNavigationBarIconBrightness,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: statusBarIconBrightness,
        systemNavigationBarColor: systemNavigationBarColor,
        systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
      ),
    );
  }

  // Screen Orientation
  Future<void> setPreferredOrientations(List<DeviceOrientation> orientations) async {
    await SystemChrome.setPreferredOrientations(orientations);
  }

  Future<void> enablePortraitOnly() async {
    await setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> enableAllOrientations() async {
    await setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // App Lifecycle
  Future<void> minimizeApp() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
