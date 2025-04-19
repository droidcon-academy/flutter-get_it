import 'package:da_get_it/core/di/dependencies.dart';
import 'package:da_get_it/viewmodels/settings_viewmodel.dart';
import 'package:da_get_it/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup GetIt service locator
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends WatchingWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = watchIt<SettingsViewModel>();
    return MaterialApp(
      title: 'Password Safe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: viewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
