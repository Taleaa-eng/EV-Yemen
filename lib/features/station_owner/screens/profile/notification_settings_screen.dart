import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/owner_widgets.dart';

class NotificationPreferences {
  const NotificationPreferences({
    this.reviews = true,
    this.station = true,
    this.account = true,
  });

  final bool reviews;
  final bool station;
  final bool account;

  NotificationPreferences copyWith(
          {bool? reviews, bool? station, bool? account}) =>
      NotificationPreferences(
        reviews: reviews ?? this.reviews,
        station: station ?? this.station,
        account: account ?? this.account,
      );
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
    required this.initialPreferences,
  });

  final NotificationPreferences initialPreferences;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationPreferences preferences;

  @override
  void initState() {
    super.initState();
    preferences = widget.initialPreferences;
  }

  @override
  Widget build(BuildContext context) {
    final allOff =
        !preferences.reviews && !preferences.station && !preferences.account;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('إعدادات الإشعارات'),
        actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          const Text('إعدادات الإشعارات',
              textAlign: TextAlign.right, style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(
            allOff
                ? 'تم إيقاف بعض التنبيهات. اضغط على المفتاح لإعادتها.'
                : 'اختر التنبيهات التي تريد استلامها.',
            textAlign: TextAlign.right,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          _preferenceTile(
            title: 'إشعارات التقييمات الجديدة',
            value: preferences.reviews,
            onChanged: (value) => setState(
                () => preferences = preferences.copyWith(reviews: value)),
          ),
          const SizedBox(height: 16),
          _preferenceTile(
            title: 'تنبيهات حالة المحطة',
            value: preferences.station,
            onChanged: (value) => setState(
                () => preferences = preferences.copyWith(station: value)),
          ),
          const SizedBox(height: 16),
          _preferenceTile(
            title: 'تحديثات الحساب والوثائق',
            value: preferences.account,
            onChanged: (value) => setState(
                () => preferences = preferences.copyWith(account: value)),
          ),
        ],
      ),
      bottomNavigationBar: OwnerStickyAction(
        child: OwnerButton(
          label: 'حفظ الإعدادات',
          onPressed: () => Navigator.pop(context, preferences),
        ),
      ),
    );
  }

  Widget _preferenceTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      OwnerCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: value,
          activeColor: AppColors.brand,
          onChanged: onChanged,
          title: Text(title,
              textAlign: TextAlign.right, style: AppTextStyles.label),
        ),
      );
}
