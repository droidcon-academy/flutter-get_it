import 'dart:async';

import 'package:da_get_it/core/di/service_locator.dart';
import 'package:da_get_it/core/services/settings_service.dart';
import 'package:da_get_it/repositories/password_repository.dart';
import 'package:da_get_it/viewmodels/password_list_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsService _settingsService;
  bool _isDarkMode = false;
  String _encryptionMethod = 'AES';
  SettingsViewModel(this._settingsService) : super() {
    _isDarkMode = _settingsService.isDarkMode;
    _encryptionMethod = _settingsService.encryptionMethod;
  }

  bool get isDarkMode => _isDarkMode;
  String get encryptionMethod => _encryptionMethod;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    _settingsService.setDarkMode(value);
    notifyListeners();
  }

  void setEncryptionMethod(String method) {
    _encryptionMethod = method;
    _settingsService.setEncryptionMethod(method);
   // getIt.reset();
    notifyListeners();
  }
}
