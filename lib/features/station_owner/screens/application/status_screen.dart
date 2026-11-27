import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../utils/owner_feedback.dart';
import '../../widgets/owner_widgets.dart';
import '../auth/login_screen.dart';
import '../auth/registration_screen.dart';
import '../dashboard/owner_home_screen.dart';
import '../../services/station_owner_local_store.dart';

enum ApplicationStatus { pending, rejected, approved }

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key, required this.status});
  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final profile = StationOwnerLocalStore.instance.currentAccount?.profile;
    final rejected = status == ApplicationStatus.rejected;
    final approved = status == ApplicationStatus.approved;
    final appBarTitle = rejected
        ? 'تم رفض طلبك'
        : approved
            ? 'تم اعتماد حسابك'
            : 'قيد المراجعة';
    final heading = rejected
        ? 'تعذّر اعتماد الحساب'
        : approved
            ? 'تم اعتماد حسابك'
            : 'طلبك قيد المراجعة';
    final subtitle = rejected
        ? 'يمكنك تعديل البيانات وإعادة إرسال الطلب.'
        : approved
            ? 'أهلاً بك في EV YEMEN. أضف محطاتك وابدأ بإدارة خدمات الشحن.'
            : 'وصل طلب ${profile?.establishment.isNotEmpty == true ? profile!.establishment : 'صاحب المحطة'}. سنرسل إشعاراً عند اكتمال المراجعة.';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(appBarTitle),
        actions: [
          if (Navigator.of(context).canPop())
            OwnerBackAction(onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(heading, textAlign: TextAlign.right, style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.right, style: AppTextStyles.body),
          const SizedBox(height: 16),
          if (rejected)
            OwnerCard(
                child: const Text(
                    'صورة ترخيص تشغيل المحطة غير واضحة. يرجى رفع نسخة كاملة وسارية المفعول.',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body))
          else if (approved)
            OwnerCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Text(profile?.establishment ?? 'حساب صاحب محطة EV Yemen',
                      textAlign: TextAlign.right, style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(profile?.city ?? '',
                      textAlign: TextAlign.right, style: AppTextStyles.caption)
                ]))
          else
            OwnerCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Text('رقم الطلب: EV-2026-0148',
                      textAlign: TextAlign.right, style: AppTextStyles.body),
                  const SizedBox(height: 8),
                  const Text('الحالة: قيد المراجعة',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 5),
                  const Text('عادةً تستغرق المراجعة يومي عمل.',
                      textAlign: TextAlign.right, style: AppTextStyles.caption)
                ])),
          if (StationOwnerLocalStore
                  .instance.currentAccount?.documents.isNotEmpty ==
              true) ...[
            const SizedBox(height: 14),
            const Text('الوثائق المقدمة',
                textAlign: TextAlign.right, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            OwnerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final document in StationOwnerLocalStore
                      .instance.currentAccount!.documents.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '${document.name} • ${(document.size / 1024).ceil()} KB',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (rejected || approved) ...[
            const SizedBox(height: 14),
            OwnerButton(
                label: 'العودة إلى تسجيل الدخول',
                outlined: true,
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false))
          ],
          if (!rejected && !approved) ...[
            const SizedBox(height: 12),
            OwnerButton(
                label: 'تحديث حالة الطلب',
                outlined: true,
                onPressed: () => showOwnerMessage(
                    context, 'حالة الطلب ما زالت قيد المراجعة.')),
            const SizedBox(height: 8),
            OwnerButton(
                label: 'التواصل مع الدعم',
                outlined: true,
                onPressed: () => showOwnerMessage(
                    context, 'الدعم متاح على الرقم +967 1 234 567'))
          ]
        ]),
      ),
      bottomNavigationBar: OwnerStickyAction(
          child: OwnerButton(
              label: rejected
                  ? 'تصحيح الطلب وإعادة الإرسال'
                  : approved
                      ? 'الدخول إلى لوحة التحكم'
                      : 'العودة إلى تسجيل الدخول',
              onPressed: () {
                if (rejected) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const RegistrationScreen(initialStep: 2)));
                } else if (approved) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const OwnerHome()),
                      (route) => false);
                } else {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false);
                }
              })),
    );
  }
}
