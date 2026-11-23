import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/owner_widgets.dart';

class LogoutConfirmationScreen extends StatelessWidget {
  const LogoutConfirmationScreen({
    super.key,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('تأكيد تسجيل الخروج'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            OwnerCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('هل تريد تسجيل الخروج؟',
                      textAlign: TextAlign.right, style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  const Text(
                    'ستحتاج إلى تسجيل الدخول مرة أخرى لإدارة محطاتك.',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 14),
                  OwnerButton(
                    label: 'تسجيل الخروج',
                    danger: true,
                    onPressed: onConfirm,
                  ),
                  const Divider(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
