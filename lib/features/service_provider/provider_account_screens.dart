import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/services/active_role_session.dart';
import '../../core/widgets/logout_confirmation_dialog.dart';
import '../../core/widgets/business_branches_screen.dart';
import '../../core/theme/app_text_styles.dart';
import '../account_selection/account_type_selection_screen.dart';
import '../station_owner/widgets/owner_widgets.dart';
import 'provider_local_store.dart';
import 'provider_documents_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key, required this.subtype});
  final String subtype;
  ProviderLocalStore get store => ProviderLocalStore.instance;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('الملف الشخصي'),
            centerTitle: true),
        body: ProviderProfileTab(subtype: subtype),
      );
}

class ProviderProfileTab extends StatelessWidget {
  const ProviderProfileTab({super.key, required this.subtype});
  final String subtype;
  ProviderLocalStore get store => ProviderLocalStore.instance;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: store,
        builder: (context, _) =>
            ListView(padding: const EdgeInsets.all(20), children: [
          Row(children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: store.profile['storeImagePath'] != null &&
                      File(store.profile['storeImagePath']!).existsSync()
                  ? FileImage(File(store.profile['storeImagePath']!))
                  : null,
              child: store.profile['storeImagePath'] == null
                  ? const Icon(Icons.storefront_outlined)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  Text(store.profile['name'] ?? subtype,
                      style: AppTextStyles.h2),
                  Text(store.profile['phone'] ?? 'أكمل بيانات حسابك',
                      style: AppTextStyles.caption)
                ]))
          ]),
          const SizedBox(height: 16),
          AppCard(
              child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('الخدمة متوفرة حالياً'),
                  subtitle: Text(store.available
                      ? 'تظهر للعملاء كمتاح'
                      : 'غير متاح للعملاء'),
                  value: store.available,
                  onChanged: store.setAvailable)),
          const SizedBox(height: 12),
          _menu(
              context,
              'إدارة الفروع',
              Icons.store_mall_directory_outlined,
              () => _push(
                  context,
                  BusinessBranchesScreen(
                    businessKey: subtype == 'صاحب قطع غيار'
                        ? 'parts_provider'
                        : 'workshop_owner',
                    title: subtype,
                  ))),
          _menu(context, 'الوثائق والمتطلبات', Icons.description_outlined,
              () => _push(context, ProviderDocumentsScreen(subtype: subtype))),
          _menu(
              context,
              'تعديل الحساب',
              Icons.edit_outlined,
              () =>
                  _push(context, ProviderEditProfileScreen(subtype: subtype))),
          _menu(context, 'الإشعارات', Icons.notifications_none_rounded,
              () => _push(context, const ProviderNotificationsScreen())),
          _menu(context, 'إعدادات الإشعارات', Icons.tune_rounded,
              () => _push(context, const ProviderNotificationSettingsScreen())),
          _menu(context, 'الدعم والمساعدة', Icons.support_agent_rounded,
              () => _push(context, const ProviderSupportScreen())),
          _menu(context, 'الخصوصية', Icons.privacy_tip_outlined,
              () => _push(context, const ProviderPrivacyScreen())),
          const SizedBox(height: 12),
          OwnerButton(
              label: 'تسجيل الخروج',
              outlined: true,
              onPressed: () => _confirmLogout(context)),
        ]),
      );

  void _push(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  Widget _menu(BuildContext context, String label, IconData icon,
          VoidCallback onTap) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
              child: ListTile(
                  onTap: onTap,
                  contentPadding: EdgeInsets.zero,
                  title: Text(label, textAlign: TextAlign.right),
                  leading: Icon(icon),
                  trailing: const Icon(Icons.chevron_left_rounded))));
  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showLogoutConfirmationDialog(context);
    if (confirm == true && context.mounted) {
      await ActiveRoleSessionStore.instance.clear();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(
              builder: (_) => const AccountTypeSelectionScreen()),
          (_) => false);
    }
  }
}

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({super.key, required this.subtype});
  final String subtype;
  @override
  State<ProviderEditProfileScreen> createState() =>
      _ProviderEditProfileScreenState();
}

class _ProviderEditProfileScreenState extends State<ProviderEditProfileScreen> {
  final controllers = <String, TextEditingController>{};
  final store = ProviderLocalStore.instance;
  @override
  void initState() {
    super.initState();
    for (final key in [
      'name',
      'phone',
      'email',
      'business',
      'city',
      'address',
      'registration',
      'category',
    ]) {
      controllers[key] = TextEditingController(text: store.profile[key] ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('تعديل الحساب'),
          centerTitle: true,
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        for (final field in [
          ('name', 'الاسم الكامل'),
          ('phone', 'رقم الهاتف'),
          ('email', 'البريد الإلكتروني'),
          ('business', 'اسم المنشأة'),
          ('city', 'المدينة'),
          ('address', 'العنوان'),
          ('registration', 'رقم السجل التجاري'),
          ('category', 'التخصص / نوع النشاط')
        ])
          Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomLabeledTextField(
                  label: field.$2,
                  controller: controllers[field.$1],
                  keyboardType:
                      field.$1 == 'phone' ? TextInputType.phone : null,
                  textDirection: field.$1 == 'phone' ? TextDirection.ltr : null,
                  textAlign:
                      field.$1 == 'phone' ? TextAlign.left : TextAlign.right)),
        const SizedBox(height: 12),
        OwnerButton(
            label: 'حفظ التعديلات',
            onPressed: () async {
              await store.saveProfile(controllers
                  .map((key, value) => MapEntry(key, value.text.trim())));
              if (context.mounted) Navigator.pop(context);
            })
      ]));
}

class ProviderNotificationSettingsScreen extends StatelessWidget {
  const ProviderNotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = ProviderLocalStore.instance;
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('إعدادات الإشعارات'),
            centerTitle: true,
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: AnimatedBuilder(
            animation: store,
            builder: (context, _) =>
                ListView(padding: const EdgeInsets.all(20), children: [
                  for (final item in [
                    ('reviews', 'تقييمات العملاء'),
                    ('account', 'الحساب والتحديثات'),
                    ('offers', 'العروض والتنبيهات')
                  ])
                    AppCard(
                        child: SwitchListTile(
                            title: Text(item.$2, textAlign: TextAlign.right),
                            value: store.notifications[item.$1] ?? false,
                            onChanged: (value) => store.saveNotifications(
                                {...store.notifications, item.$1: value}))),
                  const SizedBox(height: 12),
                  const Text('يتم حفظ اختياراتك تلقائياً على هذا الجهاز.',
                      textAlign: TextAlign.right, style: AppTextStyles.caption)
                ])));
  }
}

class ProviderNotificationsScreen extends StatelessWidget {
  const ProviderNotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('الإشعارات'),
          centerTitle: true,
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: ListView(padding: const EdgeInsets.all(20), children: const [
        AppCard(
            child: ListTile(
                leading: Text('اليوم'),
                title: Text('تقييم جديد'),
                subtitle: Text('أضاف أحد العملاء تقييماً لخدمتك.'))),
        SizedBox(height: 12),
        AppCard(
            child: ListTile(
                leading: Text('أمس'),
                title: Text('حالة الحساب'),
                subtitle: Text('يمكنك تحديث بيانات ملفك الشخصي.')))
      ]));
}

class ProviderSupportScreen extends StatelessWidget {
  const ProviderSupportScreen({super.key});
  @override
  Widget build(BuildContext context) => const _InfoScreen(
      title: 'الدعم والمساعدة',
      text:
          'للمساعدة في حساب مزود الخدمة، تواصل مع فريق EV Yemen عبر مركز الدعم.');
}

class ProviderPrivacyScreen extends StatelessWidget {
  const ProviderPrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) => const _InfoScreen(
      title: 'الخصوصية',
      text: 'تُستخدم بيانات حسابك وموقع منشأتك لتقديم خدمات EV Yemen للعملاء.');
}

class _InfoScreen extends StatelessWidget {
  const _InfoScreen({required this.title, required this.text});
  final String title, text;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(title),
          centerTitle: true,
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: AppCard(
              child: Text(text,
                  textAlign: TextAlign.right, style: AppTextStyles.body))));
}
