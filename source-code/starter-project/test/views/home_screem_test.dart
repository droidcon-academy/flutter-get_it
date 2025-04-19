// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:da_get_it/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:da_get_it/models/password_model.dart';
import 'package:da_get_it/viewmodels/password_list_viewmodel.dart';
import 'package:da_get_it/repositories/password_repository.dart';
import 'package:da_get_it/core/di/service_locator.dart';
import 'package:mocktail/mocktail.dart';

class MockPasswordRepository extends Mock implements PasswordRepository {}

void main() {
  setUp(() {
    // Register mock repository with get_it
    getIt.registerSingleton<PasswordRepository>(
      MockPasswordRepository(),
    );

    getIt.registerLazySingleton<PasswordListViewModel>(
      () => PasswordListViewModel(
        getIt<PasswordRepository>(),
      ),
    );
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('should display 2 password items', (WidgetTester tester) async {
    // Create mock password items
    final mockPasswords = [
      PasswordModel(
        title: 'Google Account',
        username: 'user1@gmail.com',
        password: 'password1',
        url: 'https://google.com',
        category: 'Social',
        createdAt: DateTime.now(),
      ),
      PasswordModel(
        title: 'GitHub',
        username: 'user2',
        password: 'password2',
        url: 'https://github.com',
        category: 'Development',
        createdAt: DateTime.now(),
      ),
    ];

    final mockPasswordRepository = getIt<PasswordRepository>();
    // Mock the repository to return our test passwords
    when(() => mockPasswordRepository.getAllPasswords())
        .thenAnswer((_) async => mockPasswords);

    // Build our app and trigger a frame
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Wait for the initial load
    await tester.pumpAndSettle();

    // Verify that both password items are displayed
    expect(find.text('Google Account'), findsOneWidget);
    expect(find.text('user1@gmail.com'), findsOneWidget);
    expect(find.text('Social'), findsOneWidget);

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('user2'), findsOneWidget);
    expect(find.text('Development'), findsOneWidget);

    // Verify that the repository was called
    verify(() => mockPasswordRepository.getAllPasswords()).called(1);
  });
}
