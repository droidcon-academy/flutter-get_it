import 'package:da_get_it/models/category_model.dart';
import 'package:da_get_it/models/password_model.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

Future<void> initializeData(Isar isar) async {
  final categoriesCount = await isar.categoryModels.count();
  final passwordsCount = await isar.passwordModels.count();
  if (categoriesCount == 0 && passwordsCount == 0) {
    try {
      // Initialize categories
      for (final categoryData in _initialData['categories']) {
        final category = CategoryModel.create(categoryData);
        await isar.writeTxn(() async {
          await isar.categoryModels.put(category);
        });
      }

      // Initialize passwords
      for (final passwordData in (_initialData['passwords'])) {
        final password = PasswordModel.create(passwordData);
        await isar.writeTxn(() async {
          await isar.passwordModels.put(password);
        });
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }
}

const _initialData = <String, dynamic>{
  'categories': [
    {
      'name': 'Social Media',
      'iconName': 'social_media',
      'colorCode': '#4267B2',
    },
    {
      'name': 'Email',
      'iconName': 'email',
      'colorCode': '#DB4437',
    },
    {
      'name': 'Banking',
      'iconName': 'banking',
      'colorCode': '#1E7F38',
    },
    {
      'name': 'Shopping',
      'iconName': 'shopping',
      'colorCode': '#FF9900',
    },
    {
      'name': 'Work',
      'iconName': 'work',
      'colorCode': '#0077B5',
    },
  ],
  'passwords': [
    {
      'title': 'Gmail',
      'username': 'user@gmail.com',
      'password': 'google@123',
      'url': 'https://gmail.com',
      'category': 'Email',
      'notes': 'My main email account',
    },
    {
      'title': 'Facebook',
      'username': 'user@example.com',
      'password': 'facebook@123',
      'url': 'https://facebook.com',
      'category': 'Social Media',
      'notes': 'Personal account',
    },
    {
      'title': 'Bank Account',
      'username': 'user123',
      'password': 'bank@123',
      'url': 'https://bank.com',
      'category': 'Banking',
      'notes': 'Main checking account',
    },
  ],
};
