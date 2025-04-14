import 'package:da_get_it/core/di/service_locator.dart';
import 'package:da_get_it/models/password_model.dart';
import 'package:da_get_it/viewmodels/category_viewmodel.dart';
import 'package:da_get_it/viewmodels/password_detail_viewmodel.dart';
import 'package:da_get_it/widgets/messages.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:watch_it/watch_it.dart';

class AddPasswordScreen extends WatchingStatefulWidget {
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passwordViewModel = watchIt<PasswordDetailViewModel>();
    final categoryViewModel = watchIt<CategoryViewModel>();
    final isLoading =
        passwordViewModel.isLoading || categoryViewModel.isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Password' : 'New Password'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _savePassword,
        child: const Icon(Icons.save),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('ITEM DETAILS'),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Item name (required)',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
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
                      ),
                      _buildSectionHeader('LOGIN CREDENTIALS'),
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
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
                      _buildSectionHeader('AUTOFILL OPTIONS'),
                      _buildTextField(
                        controller: _urlController,
                        label: 'Website (URI)',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a URL';
                          }
                          return null;
                        },
                      ),
                      _buildSectionHeader('NOTES'),
                      _buildTextField(
                        controller: _notesController,
                        label: 'Your additional notes (optional)',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _savePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final password = _buildPasswordModel();
      final result = await _passwordViewModel.savePassword(password);
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPassword)
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
          ],
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: validator,
    );
  }
}
