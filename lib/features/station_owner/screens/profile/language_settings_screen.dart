import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/owner_widgets.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key, required this.language});

  final String language;

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.language;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('لغة التطبيق'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const Text('لغة التطبيق',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 8),
            const Text('اختر لغة العرض داخل التطبيق.',
                textAlign: TextAlign.right, style: AppTextStyles.body),
            const SizedBox(height: 16),
            _languageCard('العربية', selected == 'العربية'),
            const SizedBox(height: 12),
            OwnerButton(
              label: 'English',
              outlined: selected != 'English',
              onPressed: () => setState(() => selected = 'English'),
            ),
          ],
        ),
        bottomNavigationBar: OwnerStickyAction(
          child: OwnerButton(
            label: 'حفظ اللغة',
            onPressed: () => Navigator.pop(context, selected),
          ),
        ),
      );

  Widget _languageCard(String label, bool active) => OwnerCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label,
                textAlign: TextAlign.right, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text(
              active ? 'محددة حالياً' : 'متاحة للاختيار',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption.copyWith(
                color: active ? AppColors.brand : AppColors.secondary,
              ),
            ),
          ],
        ),
      );
}
