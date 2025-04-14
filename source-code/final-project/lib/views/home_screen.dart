import 'package:da_get_it/viewmodels/password_list_viewmodel.dart';
import 'package:da_get_it/views/add_password_screen.dart';
import 'package:da_get_it/views/categories_list.dart';
import 'package:da_get_it/views/password_list.dart';
import 'package:da_get_it/views/settings_list.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class HomeScreen extends WatchingStatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final passwordViewModel = watchIt<PasswordListViewModel>();
    final isFirst = _selectedIndex == 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          if (isFirst)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: PasswordSearchDelegate(passwordViewModel),
                );
              },
            ),
        ],
      ),
      body: _getBody(),
      floatingActionButton: isFirst
          ? FloatingActionButton(
              onPressed: () => _openAddPasswordPage(context, passwordViewModel),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.lock),
            label: 'My Vault',
          ),
          NavigationDestination(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
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
        return const CategoriesList();
      case 2:
        return const SettingsList();
      default:
        return const PasswordList();
    }
  }

  void _openAddPasswordPage(BuildContext context, PasswordListViewModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPasswordScreen(),
      ),
    ).then((_) => model.loadPasswords());
  }
}
