import 'package:da_get_it/core/database/isar_database.dart';
import 'package:da_get_it/core/services/encryption_service.dart';
import 'package:da_get_it/core/services/settings_service.dart';
import 'package:da_get_it/repositories/category_repository.dart';
import 'package:da_get_it/repositories/password_repository.dart';
import 'package:da_get_it/viewmodels/category_viewmodel.dart';
import 'package:da_get_it/viewmodels/password_detail_viewmodel.dart';
import 'package:da_get_it/viewmodels/password_list_viewmodel.dart';
import 'package:da_get_it/viewmodels/settings_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

/// Sets up the service locator
Future<void> setupServiceLocator() async {
  // Core Services (Singleton)
  getIt.registerSingletonAsync<IsarDatabase>(() async {
    final isar = await IsarDatabase.init();
    return IsarDatabase(isar);
  });

  getIt.registerSingleton<EncryptionService>(EncryptionService());

  // Initialize SharedPreferences
  getIt.registerSingletonAsync<SharedPreferences>(() {
    return SharedPreferences.getInstance();
  });

  // Settings Service (Lazy Singleton)
  getIt.registerSingletonWithDependencies<SettingsService>(
    () => SettingsService(getIt<SharedPreferences>()),
    dependsOn: [SharedPreferences],
  );

  // Repositories (Lazy Singleton)
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<IsarDatabase>()),
  );

  getIt.registerLazySingleton<PasswordRepository>(
    () => PasswordRepository(getIt<IsarDatabase>(), getIt<EncryptionService>()),
  );

  // ViewModels (Factory - created new each time)
  getIt.registerCachedFactoryParam<PasswordDetailViewModel, int?, void>(
    (passwordId, _) => PasswordDetailViewModel(
      getIt<PasswordRepository>(),
      passwordId,
    ),
  );

  getIt.registerCachedFactory<PasswordListViewModel>(
    () => PasswordListViewModel(getIt<PasswordRepository>()),
  );

  getIt.registerCachedFactory<CategoryViewModel>(
    () => CategoryViewModel(getIt<CategoryRepository>()),
  );

  getIt.registerSingletonWithDependencies<SettingsViewModel>(
    () => SettingsViewModel(getIt<SettingsService>()),
    dependsOn: [SettingsService],
  );

  return getIt.allReady();
}
