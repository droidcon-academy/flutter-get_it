import 'package:da_get_it/core/services/settings_service.dart';
import 'package:flutter/foundation.dart';

class SettingsViewModel extends ValueNotifier<bool> {
  final SettingsService _settingsService;

  SettingsViewModel(this._settingsService) : super(_settingsService.isDarkMode);

  bool get isDarkMode => value;

  void toggleDarkMode(bool givenValue) {
    value = givenValue;
    _settingsService.setDarkMode(givenValue);
  }
}
