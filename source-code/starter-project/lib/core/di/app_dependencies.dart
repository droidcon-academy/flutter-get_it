import 'package:da_get_it/core/database/isar_database.dart';
import 'package:da_get_it/core/services/encryption_service.dart';
import 'package:da_get_it/core/services/settings_service.dart';
import 'package:da_get_it/repositories/category_repository.dart';
import 'package:da_get_it/repositories/password_repository.dart';
import 'package:da_get_it/viewmodels/category_viewmodel.dart';
import 'package:da_get_it/viewmodels/password_detail_viewmodel.dart';
import 'package:da_get_it/viewmodels/password_list_viewmodel.dart';
import 'package:da_get_it/viewmodels/settings_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  static final AppDependencies _instance = AppDependencies._internal();
  static AppDependencies get instance => _instance;
  AppDependencies._internal();

  // Core Services
  IsarDatabase? _database;
  SharedPreferences? _sharedPreferences;
  SettingsService? _settingsService;
  Map<String, EncryptionService>? _encryptionServices;

  // Repositories
  CategoryRepository? _categoryRepository;
  PasswordRepository? _passwordRepository;

  // ViewModels
  SettingsViewModel? _settingsViewModel;
  CategoryViewModel? _categoryViewModel;
  PasswordListViewModel? _passwordListViewModel;

  Future<void> initialize() async {
    // Initialize core services
    _database = IsarDatabase(await IsarDatabase.init());
    _sharedPreferences = await SharedPreferences.getInstance();
    _settingsService = SettingsService(_sharedPreferences!);

    // Initialize encryption services
    _encryptionServices = {
      'AES': EncryptionService.createAES(),
      'RSA': EncryptionService.createRSA(),
    };

    // Initialize repositories
    _categoryRepository = CategoryRepository(_database!);
    _passwordRepository = PasswordRepository(
      _database!,
      _encryptionServices![_settingsService!.encryptionMethod]!,
    );

    // Initialize viewmodels
    _settingsViewModel = SettingsViewModel(_settingsService!);
    _categoryViewModel = CategoryViewModel(_categoryRepository!);
    _passwordListViewModel = PasswordListViewModel(_passwordRepository!);
  }

  // Getters for repositories
  CategoryRepository get categoryRepository {
    if (_categoryRepository == null) {
      throw Exception(
          'AppDependencies not initialized. Call initialize() first.');
    }
    return _categoryRepository!;
  }

  PasswordRepository get passwordRepository {
    if (_passwordRepository == null) {
      throw Exception(
          'AppDependencies not initialized. Call initialize() first.');
    }
    return _passwordRepository!;
  }

  // Getters for viewmodels
  SettingsViewModel get settingsViewModel {
    if (_settingsViewModel == null) {
      throw Exception(
          'AppDependencies not initialized. Call initialize() first.');
    }
    return _settingsViewModel!;
  }

  CategoryViewModel get categoryViewModel {
    if (_categoryViewModel == null) {
      throw Exception(
          'AppDependencies not initialized. Call initialize() first.');
    }
    return _categoryViewModel!;
  }

  PasswordListViewModel get passwordListViewModel {
    if (_passwordListViewModel == null) {
      throw Exception(
          'AppDependencies not initialized. Call initialize() first.');
    }
    return _passwordListViewModel!;
  }

  // Factory method for creating password detail viewmodel
  PasswordDetailViewModel createPasswordDetailViewModel(int? passwordId) {
    if (_passwordRepository == null || _encryptionServices == null) {
      throw Exception(
          'AppDependencies not initialized. Call initialize() first.');
    }
    return PasswordDetailViewModel(_passwordRepository!, passwordId);
  }

  // Get encryption service by method
  EncryptionService getEncryptionService(String method) {
    if (_encryptionServices == null) {
      throw Exception(
          'AppDependencies not initialized. Call initialize() first.');
    }
    return _encryptionServices![method]!;
  }
}
