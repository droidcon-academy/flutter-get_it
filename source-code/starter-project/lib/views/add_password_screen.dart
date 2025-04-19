import 'package:da_get_it/core/di/app_dependencies.dart';
import 'package:da_get_it/models/password_model.dart';
import 'package:da_get_it/viewmodels/category_viewmodel.dart';
import 'package:da_get_it/viewmodels/password_detail_viewmodel.dart';
import 'package:da_get_it/widgets/messages.dart';
import 'package:da_get_it/widgets/password_widgets.dart';
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
  late final PasswordDetailViewModel _passwordViewModel;
  late final CategoryViewModel _categoryViewModel;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = '';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _passwordViewModel = AppDependencies.instance
        .createPasswordDetailViewModel(widget.editPasswordId);
    _categoryViewModel = AppDependencies.instance.categoryViewModel;
    _isEditing = widget.editPasswordId != null;

    _loadData();
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
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(
        [_passwordViewModel, _categoryViewModel],
      ),
      builder: (context, _) {
        final isLoading =
            _passwordViewModel.isLoading || _categoryViewModel.isLoading;
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Password' : 'Add Password'),
            centerTitle: true,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionHeader(title: 'ITEM DETAILS'),
                        AppTextField(
                          controller: _titleController,
                          label: 'Item name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: _categoryViewModel.categories
                              .map((category) => DropdownMenuItem(
                                    value: category.name,
                                    child: Text(category.name),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                        SectionHeader(title: 'LOGIN CREDENTIALS'),
                        AppTextField(
                          controller: _usernameController,
                          label: 'Username',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            return null;
                          },
                        ),
                        SectionHeader(title: 'AUTOFILL OPTIONS'),
                        AppTextField(
                          controller: _urlController,
                          label: 'Website (URI)',
                        ),
                        SectionHeader(title: 'NOTES'),
                        AppTextField(
                          controller: _notesController,
                          label: 'Your additional notes (optional)',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24.0),
                        ElevatedButton(
                          onPressed: _savePassword,
                          child: Text(
                              _isEditing ? 'Update Password' : 'Save Password'),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _savePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final password = PasswordModel(
        id: _isEditing
            ? (_passwordViewModel.password?.id ?? Isar.autoIncrement)
            : Isar.autoIncrement,
        title: _titleController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        url: _urlController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        category: _selectedCategory,
        createdAt: _isEditing
            ? _passwordViewModel.password?.createdAt ?? DateTime.now()
            : DateTime.now(),
      );

      final result = await _passwordViewModel.savePassword(password);
      if (result) {
        showSnackbarMsg(
          context,
          _isEditing ? 'Password updated' : 'Password saved',
        );
        Navigator.pop(context);
      } else {
        showSnackbarMsg(context, 'Failed to save password');
      }
    }
  }
}
