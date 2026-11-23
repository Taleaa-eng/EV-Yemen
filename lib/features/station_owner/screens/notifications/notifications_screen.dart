import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/owner_widgets.dart';
import '../profile/notification_settings_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
    required this.onBackToDashboard,
  });

  final NotificationPreferences preferences;
  final ValueChanged<NotificationPreferences> onPreferencesChanged;
  final VoidCallback onBackToDashboard;

  static const _notifications = [
    (
      'تقييم جديد لمحطة النور',
      'قيّمت سارة العريقي المحطة بـ ٥ نجوم.',
      'منذ ساعتين · عدن',
    ),
    (
      'تم تحديث حالة المحطة',
      'محطة صنعاء المركزية تعمل بشكل طبيعي.',
      'أمس · صنعاء',
    ),
    (
      'تذكير بمراجعة بيانات المنشأة',
      'تأكد من سريان ترخيص تشغيل المحطة.',
      'قبل ٣ أيام',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('الإشعارات'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const Text('الإشعارات',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 12),
            for (final item in _notifications) ...[
              OwnerCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(item.$1,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 6),
                    Text(item.$2,
                        textAlign: TextAlign.right, style: AppTextStyles.body),
                    const SizedBox(height: 8),
                    Text(item.$3,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
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
          ],
        ),
        bottomNavigationBar: OwnerStickyAction(
          child: OwnerButton(
            label: 'العودة إلى لوحة التحكم',
            onPressed: onBackToDashboard,
          ),
        ),
      );
}
