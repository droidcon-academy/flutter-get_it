import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _darkModeKey = 'dark_mode';
  static const String _biometricAuthKey = 'biometric_auth';
  static const String _autoLockKey = 'auto_lock';
  static const String _lockTimeoutKey = 'lock_timeout';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Dark mode
  bool get isDarkMode => _prefs.getBool(_darkModeKey) ?? false;

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_darkModeKey, value);
  }

  // Biometric authentication
  bool get isBiometricAuthEnabled => _prefs.getBool(_biometricAuthKey) ?? false;

  Future<void> setBiometricAuthEnabled(bool value) async {
    await _prefs.setBool(_biometricAuthKey, value);
  }

  // Auto lock
  bool get isAutoLockEnabled => _prefs.getBool(_autoLockKey) ?? true;

  Future<void> setAutoLockEnabled(bool value) async {
    await _prefs.setBool(_autoLockKey, value);
  }

  // Lock timeout (in minutes)
  int get lockTimeout => _prefs.getInt(_lockTimeoutKey) ?? 5;

  Future<void> setLockTimeout(int minutes) async {
    await _prefs.setInt(_lockTimeoutKey, minutes);
  }
}
