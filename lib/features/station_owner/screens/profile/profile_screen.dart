import 'package:flutter/material.dart';
import 'dart:io';

import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/owner_widgets.dart';
import '../../models/owner_profile.dart';
import '../../services/station_owner_local_store.dart';

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
  Widget build(BuildContext context) {
    final imagePath = profile?.storeImagePath;
    final documents =
        StationOwnerLocalStore.instance.currentAccount?.documents ?? const {};
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        const Text('بيانات المؤسسة / المحطة',
            textAlign: TextAlign.right, style: AppTextStyles.h1),
        const SizedBox(height: 12),
        if (imagePath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: File(imagePath).existsSync()
                ? Image.file(File(imagePath), height: 160, fit: BoxFit.cover)
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
        ],
        _ProfileValueCard(
          label: 'اسم المالك',
          value: profile?.fullName.isNotEmpty == true ? profile!.fullName : '—',
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
        const SectionTitle('الوثائق والمتطلبات'),
        const SizedBox(height: 12),
        OwnerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in const {
                'identity': 'الهوية الشخصية',
                'commercial_register': 'السجل التجاري',
                'activity_license': 'ترخيص تشغيل محطة الشحن',
                'premises_proof': 'إثبات ملكية / إيجار الموقع',
              }.entries) ...[
                Row(
                  children: [
                    Icon(
                      documents.containsKey(entry.key)
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: documents.containsKey(entry.key)
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entry.value,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.label),
                    ),
                  ],
                ),
                if (documents[entry.key] case final document?)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${document.name} • ${(document.size / 1024).ceil()} KB',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  )
                else
                  const Text('لم يتم إرفاقه',
                      textAlign: TextAlign.right, style: AppTextStyles.caption),
                if (entry.key != 'premises_proof') const Divider(height: 20),
              ],
            ],
          ),
        ),
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
