# Password Safe App with GetIt Dependency Injection

This is a Flutter application that demonstrates how to use GetIt for dependency injection in a password manager app.

## About the Project

This app is designed to showcase the usage of dependency injection with GetIt, providing a clean architecture that separates UI, business logic, and data layers.

### Features

- Securely store and manage passwords
- Categorize passwords for easy organization
- Search and filter functionality
- Encryption for sensitive data
- Settings for app customization

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture:

- Models: Data classes for the app (Password, Category)
- Views: UI screens and widgets
- ViewModels: Classes that handle UI logic and state
- Repositories: Handle data operations
- Services: Provide core functionality

### Dependency Injection

GetIt is used for dependency injection, making it easy to:

- Resolve dependencies throughout the app
- Mock services for testing
- Reduce tight coupling between components
- Manage object lifecycles

## Implementation Details

### Directory Structure

```
lib/
├── core/
│   ├── database/            # Isar database setup
│   ├── services/            # Encryption, Settings
│   ├── di/                  # GetIt setup
├── models/                  # Data models
├── repositories/            # Data operations
├── viewmodels/              # UI logic
├── views/                   # UI screens
├── widgets/                 # Reusable UI components
├── main.dart                # App entry point
```

### GetIt Registration Types

The app uses different GetIt registration types:

- **Singleton**: For services that should have only one instance throughout the app lifecycle
- **Lazy Singleton**: For services that should be created only when needed, then reused
- **Factory**: For objects that should be created fresh each time they're requested
- **Factory Parameters**: For objects that require parameters during creation and should be created fresh each time

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter pub run build_runner build` to generate the required Isar models
4. Run the app with `flutter run`

## Dependencies

- get_it: Service locator for dependency injection
- watch_it: State management and dependency watching
- isar: Local database with encryption support
- shared_preferences: Store app settings

## License

This project is for educational purposes and is not intended for production use.
