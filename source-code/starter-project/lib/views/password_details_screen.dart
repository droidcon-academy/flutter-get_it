import 'package:da_get_it/core/di/app_dependencies.dart';
import 'package:da_get_it/viewmodels/password_detail_viewmodel.dart';
import 'package:da_get_it/views/add_password_screen.dart';
import 'package:da_get_it/widgets/password_widgets.dart';
import 'package:flutter/material.dart';

class PasswordDetailsScreen extends StatelessWidget {
  final int passwordId;

  const PasswordDetailsScreen({
    super.key,
    required this.passwordId,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel =
        AppDependencies.instance.createPasswordDetailViewModel(passwordId);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Password Details'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPasswordScreen(
                        editPasswordId: passwordId,
                      ),
                    ),
                  ).then((_) => viewModel.loadPassword(passwordId));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, viewModel),
              ),
            ],
          ),
          body: _PasswordForm(viewModel: viewModel),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, PasswordDetailViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Password'),
        content: Text(
            'Are you sure you want to delete "${viewModel.password?.title}"?'),
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
      await viewModel.deletePassword();
      Navigator.pop(context);
    }
  }
}

class _PasswordForm extends StatelessWidget {
  const _PasswordForm({required this.viewModel});
  final PasswordDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final password = viewModel.password;
        if (password == null) {
          return const Center(child: Text('Password not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'ITEM DETAILS'),
              AppTextField(
                controller: TextEditingController(text: password.title),
                label: 'Item name',
                canCopy: true,
                isReadOnly: true,
              ),
              AppTextField(
                controller: TextEditingController(text: password.category),
                label: 'Category',
                isReadOnly: true,
              ),
              SectionHeader(title: 'LOGIN CREDENTIALS'),
              AppTextField(
                controller: TextEditingController(text: password.username),
                label: 'Username',
                canCopy: true,
                isReadOnly: true,
              ),
              AppTextField(
                controller:
                    TextEditingController(text: viewModel.decryptedPassword),
                label: 'Password',
                canCopy: true,
                isPassword: true,
              ),
              SectionHeader(title: 'AUTOFILL OPTIONS'),
              AppTextField(
                controller: TextEditingController(text: password.url),
                label: 'Website (URI)',
                canCopy: true,
                isReadOnly: true,
              ),
              if (password.notes != null && password.notes!.isNotEmpty) ...[
                SectionHeader(title: 'NOTES'),
                AppTextField(
                  controller: TextEditingController(text: password.notes!),
                  label: 'Your additional notes (optional)',
                  canCopy: true,
                  isReadOnly: true,
                ),
              ],
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Created on: ${_formatDate(password.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (password.updatedAt != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Last updated: ${_formatDate(password.updatedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final formatted = '${date.day}/${date.month}/${date.year}';
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');

    return '$formatted $hour:$minute';
  }
}
