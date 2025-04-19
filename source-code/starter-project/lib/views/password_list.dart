import 'dart:async';

import 'package:da_get_it/core/di/app_dependencies.dart';
import 'package:da_get_it/models/password_model.dart';
import 'package:da_get_it/viewmodels/password_list_viewmodel.dart';
import 'package:da_get_it/views/password_details_screen.dart';
import 'package:da_get_it/widgets/messages.dart';
import 'package:da_get_it/widgets/password_widgets.dart';
import 'package:flutter/material.dart';

class PasswordList extends StatelessWidget {
  const PasswordList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = AppDependencies.instance.passwordListViewModel;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
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
              onTap: () =>
                  _navigateToPasswordDetails(context, password, viewModel),
              onDelete: () => _deletePassword(context, password, viewModel),
            );
          },
        );
      },
    );
  }

  void _navigateToPasswordDetails(
    BuildContext context,
    PasswordModel password,
    PasswordListViewModel viewModel,
  ) {
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
    PasswordListViewModel viewModel,
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
      await viewModel.deletePassword(password.id);
      scheduleMicrotask(() {
        showSnackbarMsg(context, 'Password deleted');
      });
    }
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
