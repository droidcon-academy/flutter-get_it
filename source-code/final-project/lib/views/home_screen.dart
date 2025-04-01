import 'dart:async';

import 'package:da_get_it/core/di/service_locator.dart';
import 'package:da_get_it/models/password_model.dart';
import 'package:da_get_it/viewmodels/category_viewmodel.dart';
import 'package:da_get_it/viewmodels/password_list_viewmodel.dart';
import 'package:da_get_it/views/add_password_screen.dart';
import 'package:da_get_it/views/password_details_screen.dart';
import 'package:da_get_it/views/settings_screen.dart';
import 'package:da_get_it/widgets/messages.dart';
import 'package:da_get_it/widgets/password_item.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class HomeScreen extends WatchingWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final passwordViewModel = watchIt<PasswordListViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Safe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PasswordSearchDelegate(passwordViewModel),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettingScreen(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: CategoryDrawer(),
      ),
      body: PasswordList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddPasswordPage(context, passwordViewModel),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddPasswordPage(BuildContext context, PasswordListViewModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPasswordScreen(),
      ),
    ).then((_) => model.loadPasswords());
  }

  void _openSettingScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}

class PasswordList extends WatchingWidget {
  const PasswordList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = watchIt<PasswordListViewModel>();
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.passwords.isEmpty) {
      final isCategoryEmpty = viewModel.selectedCategory.isEmpty;
      return NoPasswordFound(
        onClearTap: isCategoryEmpty ? null : () => viewModel.clearFilters(),
      );
    }

    return ListView.builder(
      itemCount: viewModel.passwords.length,
      itemBuilder: (context, index) {
        final password = viewModel.passwords[index];
        return PasswordItem(
          password: password,
          onTap: () => _navigateToPasswordDetails(context, password),
          onDelete: () => _deletePassword(context, password),
        );
      },
    );
  }

  void _navigateToPasswordDetails(
    BuildContext context,
    PasswordModel password,
  ) {
    final viewModel = getIt<PasswordListViewModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordDetailsScreen(passwordId: password.id),
      ),
    ).then((_) => viewModel.loadPasswords());
  }

  Future<void> _deletePassword(
    BuildContext context,
    PasswordModel password,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Password'),
        content: Text('Are you sure you want to delete "${password.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final viewModel = getIt<PasswordListViewModel>();
      await viewModel.deletePassword(password.id);
      scheduleMicrotask(() {
        showSnackbarMsg(context, 'Password deleted');
      });
    }
  }
}

class NoPasswordFound extends StatelessWidget {
  const NoPasswordFound({super.key, this.onClearTap});

  final VoidCallback? onClearTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No passwords yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first password',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (onClearTap != null)
            ElevatedButton(
              onPressed: onClearTap,
              child: const Text('Clear filter'),
            ),
        ],
      ),
    );
  }
}

class CategoryDrawer extends WatchingWidget {
  const CategoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final passwordViewModel = watchIt<PasswordListViewModel>();
    final categoryViewModel = watchIt<CategoryViewModel>();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Filter your passwords',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          title: const Text('All Passwords'),
          selected: passwordViewModel.selectedCategory.isEmpty,
          leading: const Icon(Icons.password),
          onTap: () {
            passwordViewModel.clearFilters();
            Navigator.pop(context);
          },
        ),
        const Divider(),
        if (categoryViewModel.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ...categoryViewModel.categories.map((category) {
            return ListTile(
              title: Text(category.name),
              selected: passwordViewModel.selectedCategory == category.name,
              leading: const Icon(Icons.folder),
              onTap: () {
                passwordViewModel.filterByCategory(category.name);
                Navigator.pop(context);
              },
            );
          }),
      ],
    );
  }
}

class PasswordSearchDelegate extends SearchDelegate<String> {
  final PasswordListViewModel _viewModel;

  PasswordSearchDelegate(this._viewModel);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 2) {
      return const Center(
        child: Text('Enter at least 2 characters to search'),
      );
    }

    _viewModel.searchPasswords(query);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_viewModel.passwords.isEmpty) {
          return const Center(
            child: Text('No passwords found'),
          );
        }

        return ListView.builder(
          itemCount: _viewModel.passwords.length,
          itemBuilder: (context, index) {
            final password = _viewModel.passwords[index];
            return ListTile(
              title: Text(password.title),
              subtitle: Text(password.username),
              leading: const Icon(Icons.lock),
              onTap: () {
                close(context, '');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordDetailsScreen(
                      passwordId: password.id,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 2) {
      return const Center(
        child: Text('Enter at least 2 characters to search'),
      );
    }

    return buildResults(context);
  }
}
