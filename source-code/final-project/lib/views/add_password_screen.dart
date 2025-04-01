import 'package:da_get_it/core/di/service_locator.dart';
import 'package:da_get_it/models/password_model.dart';
import 'package:da_get_it/viewmodels/category_viewmodel.dart';
import 'package:da_get_it/viewmodels/password_detail_viewmodel.dart';
import 'package:da_get_it/widgets/messages.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class AddPasswordScreen extends StatefulWidget {
  final int? editPasswordId;

  const AddPasswordScreen({
    super.key,
    this.editPasswordId,
  });

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  late PasswordDetailViewModel _passwordViewModel;
  late CategoryViewModel _categoryViewModel;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = '';
  bool _obscurePassword = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    // Get view models from GetIt
    _passwordViewModel = getIt<PasswordDetailViewModel>(
      param1: widget.editPasswordId,
    );
    _categoryViewModel = getIt<CategoryViewModel>();

    _isEditing = widget.editPasswordId != null;

    _loadData();
  }

  Future<void> _loadData() async {
    await _categoryViewModel.loadCategories();

    if (_categoryViewModel.categories.isNotEmpty) {
      _selectedCategory = _categoryViewModel.categories.first.name;
    }

    if (_isEditing && widget.editPasswordId != null) {
      await _passwordViewModel.loadPassword(widget.editPasswordId!);
      _populateForm();
    }
  }

  void _populateForm() {
    final password = _passwordViewModel.password;
    if (password != null) {
      _titleController.text = password.title;
      _usernameController.text = password.username;
      _passwordController.text = _passwordViewModel.decryptedPassword;
      _urlController.text = password.url;
      _notesController.text = password.notes ?? '';
      _selectedCategory = password.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Password' : 'Add Password'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_passwordViewModel, _categoryViewModel]),
        builder: (context, _) {
          if (_passwordViewModel.isLoading || _categoryViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username / Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username or email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Website URL',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categoryViewModel.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.name,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _savePassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _isEditing ? 'Update Password' : 'Save Password',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _savePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final password = _buildPasswordModel();
      final result = await _passwordViewModel.savePassword(password);
      print('result: $mounted');
      if (result && mounted) {
        showSnackbarMsg(
          context,
          _isEditing ? 'Password updated' : 'Password saved',
        );
        Navigator.pop(context);
      }
    }
  }

  PasswordModel _buildPasswordModel() {
    final password = PasswordModel(
      id: _isEditing && _passwordViewModel.password != null
          ? _passwordViewModel.password!.id
          : Isar.autoIncrement,
      title: _titleController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      url: _urlController.text,
      category: _selectedCategory,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: _isEditing && _passwordViewModel.password != null
          ? _passwordViewModel.password!.createdAt
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return password;
  }
}
