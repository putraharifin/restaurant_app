import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/settings_provider.dart';
import 'package:restaurant_app/ui/widgets/screen_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _toggleReminder(
    BuildContext context,
    SettingsProvider settings,
    bool value,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await settings.setDailyReminder(value);

    final message = switch (result) {
      ReminderToggleResult.success => null,
      ReminderToggleResult.permissionDenied =>
        'Izin notifikasi ditolak. Aktifkan melalui pengaturan aplikasi.',
      ReminderToggleResult.failed =>
        'Gagal mengatur pengingat. Silakan coba lagi.',
    };
    if (message == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(
              title: 'Setting',
              subtitle: 'Customize your experience',
            ),
            Expanded(
              child: Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Theme'),
                        subtitle: const Text('Gunakan tampilan gelap'),
                        value: settings.isDarkTheme,
                        onChanged: settings.setDarkTheme,
                      ),
                      SwitchListTile(
                        title: const Text('Restaurant Notification'),
                        subtitle: const Text(
                          'Enable notification: rekomendasi restoran setiap '
                          'pukul 11.00',
                        ),
                        value: settings.isDailyReminderActive,
                        onChanged: (value) =>
                            _toggleReminder(context, settings, value),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}