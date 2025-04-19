import 'package:da_get_it/core/di/app_dependencies.dart';
import 'package:da_get_it/viewmodels/password_list_viewmodel.dart';
import 'package:da_get_it/views/add_password_screen.dart';
import 'package:da_get_it/views/categories_list.dart';
import 'package:da_get_it/views/password_list.dart';
import 'package:da_get_it/views/settings_list.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final PasswordListViewModel _passwordViewModel;

  @override
  void initState() {
    super.initState();
    _passwordViewModel = AppDependencies.instance.passwordListViewModel;
  }

  void switchToFirstTab() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFirst = _selectedIndex == 0;
    return ListenableBuilder(
      listenable: _passwordViewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle()),
            actions: [
              if (isFirst)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _openAddPasswordPage(context),
                ),
            ],
          ),
          body: _getBody(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.password),
                label: 'Passwords',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Passwords Safe';
      case 1:
        return 'Categories';
      case 2:
        return 'Settings';
      default:
        return 'My Vault';
    }
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const PasswordList();
      case 1:
        return CategoriesList(onSelected: switchToFirstTab);
      case 2:
        return const SettingsList();
      default:
        return const PasswordList();
    }
  }

  void _openAddPasswordPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPasswordScreen(),
      ),
    ).then((_) => _passwordViewModel.loadPasswords());
  }
}
