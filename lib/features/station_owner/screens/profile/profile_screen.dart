import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/owner_widgets.dart';
import '../../models/owner_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onOpenSettings,
    required this.onLogout,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onLogout;
  final OwnerProfile? profile;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          const Text('بيانات المؤسسة / المحطة',
              textAlign: TextAlign.right, style: AppTextStyles.h1),
          const SizedBox(height: 12),
          _ProfileValueCard(
            label: 'اسم المالك',
            value:
                profile?.fullName.isNotEmpty == true ? profile!.fullName : '—',
          ),
          const SizedBox(height: 12),
          _ProfileValueCard(
              label: 'رقم السجل التجاري',
              value: profile?.registrationNumber.isNotEmpty == true
                  ? profile!.registrationNumber
                  : '—'),
          const SizedBox(height: 12),
          _ProfileValueCard(label: 'رقم التواصل', value: profile?.phone ?? '—'),
          const SizedBox(height: 12),
          _ProfileValueCard(
              label: 'البريد الإلكتروني', value: profile?.email ?? '—'),
          const SizedBox(height: 12),
          _ProfileValueCard(
              label: 'المنشأة والعنوان',
              value:
                  '${profile?.establishment ?? ''} · ${profile?.address ?? ''}'),
          const SizedBox(height: 16),
          const SectionTitle('الإعدادات'),
          const SizedBox(height: 12),
          OwnerButton(
            label: 'إعدادات الحساب',
            outlined: true,
            onPressed: onOpenSettings,
          ),
          const SizedBox(height: 12),
          OwnerButton(
            label: 'تسجيل الخروج',
            outlined: true,
            onPressed: onLogout,
          ),
          const SizedBox(height: 12),
          const Text('EV Yemen • الإصدار 1.0.0',
              textAlign: TextAlign.center, style: AppTextStyles.caption),
        ],
      );
}

class _ProfileValueCard extends StatelessWidget {
  const _ProfileValueCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 122,
        child: OwnerCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label,
                  textAlign: TextAlign.right, style: AppTextStyles.label),
              const SizedBox(height: 8),
              Text(value,
                  textAlign: TextAlign.right, style: AppTextStyles.body),
            ],
          ),
        ),
      );
}
