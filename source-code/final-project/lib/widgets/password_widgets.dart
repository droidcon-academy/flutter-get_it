import 'package:da_get_it/models/password_model.dart';
import 'package:da_get_it/widgets/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordItem extends StatelessWidget {
  final PasswordModel password;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PasswordItem({
    super.key,
    required this.password,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(password.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Password'),
            content:
                Text('Are you sure you want to delete "${password.title}"?'),
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
      },
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.lock),
        ),
        title: Text(password.title),
        subtitle: Text(password.username),
        trailing: Chip(
          label: Text(
            password.category,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue,
        ),
        onTap: onTap,
      ),
    );
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

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool canCopy;
  final bool isReadOnly;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.maxLines,
    this.validator,
    this.canCopy = false,
    this.isReadOnly = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: widget.isReadOnly,
      obscureText: widget.isPassword && _obscurePassword,
      maxLines: widget.maxLines ?? 1,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isPassword)
              IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            if (widget.canCopy)
              IconButton(
                icon: Icon(Icons.copy, color: Colors.grey[600]),
                onPressed: () =>
                    _copyToClipboard(context, widget.controller.text),
              ),
          ],
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: widget.validator,
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackbarMsg(context, 'Copied to clipboard');
  }
}
