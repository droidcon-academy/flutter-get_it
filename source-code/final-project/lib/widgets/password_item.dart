import 'package:da_get_it/models/password_model.dart';
import 'package:flutter/material.dart';

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