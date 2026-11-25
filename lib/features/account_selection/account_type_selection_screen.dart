import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_shared_components.dart';
import '../service_provider/auth/provider_signup_screen.dart';
import '../spare_parts_provider/spare_parts_provider_app.dart';
import '../workshop_owner/workshop_owner_app.dart';
import '../station_owner/screens/auth/login_screen.dart';
import '../station_owner/widgets/owner_widgets.dart'
    show CustomLabeledTextField, OwnerBackAction, OwnerStickyAction;

enum AccountType { customer, carDealer, serviceProvider, stationOwner }

extension AccountTypeLabels on AccountType {
  String get label => switch (this) {
        AccountType.customer => 'عميل',
        AccountType.carDealer => 'وكيل سيارات',
        AccountType.serviceProvider => 'مزود خدمة',
        AccountType.stationOwner => 'صاحب محطة',
      };

  IconData get icon => switch (this) {
        AccountType.customer => Icons.person_outline_rounded,
        AccountType.carDealer => Icons.directions_car_filled_outlined,
        AccountType.serviceProvider => Icons.construction_rounded,
        AccountType.stationOwner => Icons.ev_station_outlined,
      };
}

class AccountTypeSelectionScreen extends StatefulWidget {
  const AccountTypeSelectionScreen({super.key});

  @override
  State<AccountTypeSelectionScreen> createState() =>
      _AccountTypeSelectionScreenState();
}

class _AccountTypeSelectionScreenState
    extends State<AccountTypeSelectionScreen> {
  AccountType selected = AccountType.customer;

  Future<void> _continue() async {
    String? providerSubtype;
    if (selected == AccountType.serviceProvider) {
      providerSubtype = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('اختر نوع مزود الخدمة',
                    textAlign: TextAlign.right, style: AppTextStyles.heading),
                const SizedBox(height: 12),
                _SubtypeTile(
                  label: 'صاحب ورشة',
                  icon: Icons.build_outlined,
                  onTap: () => Navigator.pop(context, 'صاحب ورشة'),
                ),
                const SizedBox(height: 10),
                _SubtypeTile(
                  label: 'صاحب قطع غيار',
                  icon: Icons.handyman_outlined,
                  onTap: () => Navigator.pop(context, 'صاحب قطع غيار'),
                ),
              ],
            ),
          ),
        ),
      );
      if (providerSubtype == null || !mounted) return;
    }

    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => selected == AccountType.stationOwner
          ? const LoginScreen()
          : AccountLoginScreen(
              accountType: selected,
              providerSubtype: providerSubtype,
            ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('إنشاء حساب'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(21, 16, 21, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('اختر نوع الحساب المناسب',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.body),
                      const SizedBox(height: 10),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 26,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.62,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final type in AccountType.values)
                            _AccountTypeCard(
                              type: type,
                              selected: type == selected,
                              onTap: () => setState(() => selected = type),
                            ),
                        ],
                      ),
                      const SizedBox(height: 44),
                      SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: _continue,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brand,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11)),
                            textStyle: AppTextStyles.button,
                          ),
                          child: const Text('متابعة'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final AccountType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : AppColors.white,
          border: Border.all(
              color: selected ? AppColors.brand : const Color(0xFFD2DDD3),
              width: selected ? 1 : 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                if (selected)
                  const Positioned(
                    top: 7,
                    left: 7,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.white,
                      child: Icon(Icons.check_rounded,
                          size: 15, color: AppColors.brand),
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon,
                          size: 25,
                          color: selected
                              ? AppColors.white
                              : const Color(0xFF7D877E)),
                      const SizedBox(height: 5),
                      Text(type.label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: selected
                                ? AppColors.white
                                : const Color(0xFF7D877E),
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                            fontVariations: selected
                                ? const [FontVariation('wght', 600)]
                                : null,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _SubtypeTile extends StatelessWidget {
  const _SubtypeTile(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          minimumSize: const Size.fromHeight(50),
          alignment: Alignment.centerRight,
          side: const BorderSide(color: AppColors.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}

class AccountLoginScreen extends StatelessWidget {
  const AccountLoginScreen(
      {super.key, required this.accountType, this.providerSubtype});
  final AccountType accountType;
  final String? providerSubtype;

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('تسجيل الدخول'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('مرحباً بعودتك',
                  textAlign: TextAlign.right, style: AppTextStyles.h1),
              Text(
                providerSubtype == null
                    ? 'أدخل بيانات حساب ${accountType.label} للمتابعة.'
                    : 'أدخل بيانات حساب $providerSubtype للمتابعة.',
                textAlign: TextAlign.right,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 22),
              Directionality(
                textDirection: TextDirection.ltr,
                child: CustomLabeledTextField(
                  label: 'رقم الهاتف',
                  hint: '+967 ...',
                  helperText: 'أدخل رقم الهاتف المرتبط بحسابك.',
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 14),
              const CustomLabeledTextField(
                label: 'كلمة المرور',
                hint: 'أدخل كلمة المرور',
                helperText: 'استخدم كلمة مرور حسابك.',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (accountType == AccountType.serviceProvider)
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProviderSignupScreen(
                          subtype: providerSubtype ?? 'صاحب ورشة'),
                    ),
                  ),
                  child: const Text('ليس لديك حساب؟ إنشاء حساب جديد'),
                ),
            ],
          ),
        ),
        bottomNavigationBar: OwnerStickyAction(
          keyboardAware: true,
          child: AppButton(
            label: 'تسجيل الدخول',
            onPressed: accountType == AccountType.serviceProvider
                ? () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => providerSubtype == 'صاحب قطع غيار'
                            ? const SparePartsProviderApp()
                            : const WorkshopOwnerApp(),
                      ),
                    )
                : null,
          ),
        ),
      );
}
