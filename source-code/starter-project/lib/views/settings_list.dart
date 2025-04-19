import 'package:da_get_it/core/di/dependencies.dart';
import 'package:flutter/material.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = AppDependencies.instance.settingsViewModel;
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                'Appearance',
                style: titleStyle,
              ),
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: viewModel.isDarkMode,
              onChanged: viewModel.toggleDarkMode,
            ),
            const Divider(),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                'Security',
                style: titleStyle,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('AES'),
                    value: 'AES',
                    groupValue: viewModel.encryptionMethod,
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.setEncryptionMethod(value);
                        _restartApp(context);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('RSA'),
                    value: 'RSA',
                    groupValue: viewModel.encryptionMethod,
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.setEncryptionMethod(value);
                        _restartApp(context);
                      }
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                'About',
                style: titleStyle,
              ),
            ),
            ListTile(
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              title: const Text('Developer'),
              subtitle: const Text('GetIt Dependency Injection Demo'),
            ),
          ],
        );
      },
    );
  }

  void _restartApp(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (_) => false,
    );
  }
}
