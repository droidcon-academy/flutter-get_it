import 'package:da_get_it/viewmodels/password_detail_viewmodel.dart';
import 'package:da_get_it/views/add_password_screen.dart';
import 'package:da_get_it/widgets/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:da_get_it/core/di/service_locator.dart';
import 'package:watch_it/watch_it.dart';

class PasswordDetailsScreen extends WatchingWidget {
  final int passwordId;

  const PasswordDetailsScreen({
    super.key,
    required this.passwordId,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = watch(getIt<PasswordDetailViewModel>(param1: passwordId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Details'),
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
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PasswordDetailViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Password'),
        content: const Text('Are you sure you want to delete this password?'),
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
      final result = await viewModel.deletePassword();
      if (result) {
        showSnackbarMsg(context, 'Password deleted');
        Navigator.pop(context);
      }
    }
  }
}

class _FieldCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool canCopy;
  final bool isMultiline;

  const _FieldCard({
    required this.title,
    required this.content,
    required this.icon,
    this.canCopy = false,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          content,
          style: const TextStyle(fontSize: 16),
          maxLines: isMultiline ? null : 1,
        ),
        trailing: canCopy
            ? IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyToClipboard(context, content),
              )
            : null,
        isThreeLine: isMultiline,
      ),
    );
  }
}

class _PasswordForm extends StatelessWidget {
  const _PasswordForm({required this.viewModel});
  final PasswordDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
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
          _FieldCard(
            title: 'Title',
            content: password.title,
            icon: Icons.title,
          ),
          _FieldCard(
            title: 'Username / Email',
            content: password.username,
            icon: Icons.person,
            canCopy: true,
          ),
          _buildPasswordCard(context),
          _FieldCard(
            title: 'Website URL',
            content: password.url,
            icon: Icons.link,
            canCopy: true,
          ),
          _FieldCard(
            title: 'Category',
            content: password.category,
            icon: Icons.category,
          ),
          if (password.notes != null && password.notes!.isNotEmpty)
            _FieldCard(
              title: 'Notes',
              content: password.notes!,
              icon: Icons.note,
              isMultiline: true,
            ),
          const SizedBox(height: 8),
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
  }

  Widget _buildPasswordCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: const Icon(Icons.lock),
        title: const Text('Password'),
        subtitle: Text(
          viewModel.passwordVisible
              ? viewModel.decryptedPassword
              : viewModel.getMaskedPassword(),
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                viewModel.passwordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () => viewModel.togglePasswordVisibility(),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () =>
                  _copyToClipboard(context, viewModel.decryptedPassword),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

void _copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  showSnackbarMsg(context, 'Copied to clipboard');
}
