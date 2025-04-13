import 'package:da_get_it/models/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

Future<void> initCategories(Isar isar) async {
  final categoriesCount = await isar.categoryModels.count();
  if (categoriesCount == 0) {
    try {
      // Initialize categories
      for (final categoryData in _initialData['categories']) {
        final category = CategoryModel.create(categoryData);
        await isar.writeTxn(() async {
          await isar.categoryModels.put(category);
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
};
