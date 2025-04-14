import 'package:da_get_it/viewmodels/category_viewmodel.dart';
import 'package:da_get_it/viewmodels/password_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class CategoriesList extends WatchingWidget {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    final passwordViewModel = watchIt<PasswordListViewModel>();
    final categoryViewModel = watchIt<CategoryViewModel>();

    return ListView(
      children: [
        ListTile(
          title: const Text('All Passwords'),
          selected: passwordViewModel.selectedCategory.isEmpty,
          leading: const Icon(Icons.password),
          onTap: () {
            passwordViewModel.clearFilters();
          },
        ),
        const Divider(),
        if (categoryViewModel.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ...categoryViewModel.categories.map((category) {
            return ListTile(
              title: Text(category.name),
              selected: passwordViewModel.selectedCategory == category.name,
              leading: const Icon(Icons.folder),
              onTap: () {
                passwordViewModel.filterByCategory(category.name);
              },
            );
          }),
      ],
    );
  }
}
