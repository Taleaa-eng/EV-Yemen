import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/owner_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('السياسة والخصوصية'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const Text('السياسة والخصوصية',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 12),
            OwnerCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'نستخدم بيانات المنشأة والمحطة لإدارة الحساب والتحقق من الوثائق وتسهيل تواصل العملاء مع المحطة.',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'يمكنك مراجعة بيانات التواصل وتحديثها من الملف الشخصي. رقم السجل التجاري للقراءة فقط.',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'للاستفسارات، تواصل مع فريق EV YEMEN من مركز الدعم.',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: OwnerStickyAction(
          child: OwnerButton(
            label: 'العودة إلى الإعدادات',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
}
