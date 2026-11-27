import 'package:flutter/material.dart';

import '../services/business_approval_store.dart';
import '../theme/app_text_styles.dart';
import 'app_shared_components.dart';

class BusinessApprovalScreen extends StatelessWidget {
  const BusinessApprovalScreen({
    super.key,
    required this.businessKey,
    required this.businessTitle,
  });
  final String businessKey;
  final String businessTitle;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('حالة التحقق'),
          actions: [
            IconButton(
              tooltip: 'رجوع',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ],
        ),
        body: FutureBuilder<BusinessApprovalStatus>(
          future: BusinessApprovalStore.instance.statusFor(businessKey),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final status = snapshot.data!;
            final approved = status == BusinessApprovalStatus.approved;
            final rejected = status == BusinessApprovalStatus.rejected;
            final label = approved
                ? 'تمت الموافقة من الأدمن'
                : rejected
                    ? 'الطلب يحتاج إلى تعديل'
                    : 'قيد مراجعة الأدمن';
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    approved
                        ? Icons.verified_outlined
                        : rejected
                            ? Icons.error_outline_rounded
                            : Icons.hourglass_top_rounded,
                    size: 52,
                  ),
                  const SizedBox(height: 16),
                  Text(label,
                      textAlign: TextAlign.right, style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(
                    approved
                        ? 'أصبح حساب $businessTitle جاهزاً للاستخدام.'
                        : rejected
                            ? 'راجع بيانات ووثائق الحساب ثم أعد تقديم الطلب.'
                            : 'لن تتاح لوحة التحكم حتى يراجع الأدمن بيانات الحساب ووثائقه ويعتمده.',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body,
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'العودة إلى تسجيل الدخول',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        ),
      );
}
