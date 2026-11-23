import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/owner_widgets.dart';
import 'language_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
    required this.language,
    required this.onLanguageChanged,
    required this.onLogout,
  });

  final NotificationPreferences preferences;
  final ValueChanged<NotificationPreferences> onPreferencesChanged;
  final String language;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('الإعدادات'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const Text('إعدادات الحساب',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 16),
            OwnerButton(
              label: 'لغة التطبيق · $language',
              outlined: true,
              onPressed: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LanguageSettingsScreen(language: language),
                  ),
                );
                if (result != null) onLanguageChanged(result);
              },
            ),
            const SizedBox(height: 16),
            OwnerButton(
              label: 'إعدادات الإشعارات',
              outlined: true,
              onPressed: () async {
                final result = await Navigator.push<NotificationPreferences>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationSettingsScreen(
                      initialPreferences: preferences,
                    ),
                  ),
                );
                if (result != null) onPreferencesChanged(result);
              },
            ),
            const SizedBox(height: 16),
            OwnerButton(
              label: 'السياسة والخصوصية',
              outlined: true,
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
          ],
        ),
        bottomNavigationBar: OwnerStickyAction(
          child: OwnerButton(
            label: 'تسجيل الخروج',
            danger: true,
            onPressed: onLogout,
          ),
        ),
      );
}
