import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../utils/owner_feedback.dart';
import '../../widgets/owner_widgets.dart';
import '../../models/owner_profile.dart';
import '../../services/station_owner_local_store.dart';
import '../application/status_screen.dart';
import 'review_submit_screen.dart';
import '../../../service_provider/provider_map_picker.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, this.initialStep = 0, this.store});
  final int initialStep;
  final StationOwnerLocalStore? store;
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late int step;
  bool showErrors = false;
  bool submitting = false;
  bool duplicateAccount = false;
  StationOwnerLocalStore get store =>
      widget.store ?? StationOwnerLocalStore.instance;
  final controllers = List.generate(10, (_) => TextEditingController());
  final files = List<PlatformFile?>.filled(4, null);
  ProviderMapPoint? location;
  @override
  void initState() {
    super.initState();
    step = widget.initialStep;
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['البيانات الشخصية', 'بيانات المنشأة', 'الوثائق'];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(step == 0 ? 'بيانات صاحب المحطة' : titles[step]),
        actions: [
          OwnerBackAction(
            onPressed: () =>
                step > 0 ? setState(() => step--) : Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    titles[step],
                    style: AppTextStyles.h1,
                    textAlign: TextAlign.right,
                  ),
                  if (step == 2) ...[
                    const SizedBox(height: 8),
                    const Text('ارفع نسخاً واضحة بصيغة PDF أو PNG أو JPG.',
                        style: AppTextStyles.body, textAlign: TextAlign.right),
                  ],
                  const SizedBox(height: 16),
                  if (step == 0) ...[
                    _field('الاسم الكامل', 'مثال: أحمد محمد القباطي', 0),
                    const SizedBox(height: 12),
                    _field(
                      'رقم الهاتف',
                      '+967 7XX XXX XXX',
                      1,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'البريد الإلكتروني (اختياري)',
                      'ahmed.alqahtani@mail.ye',
                      2,
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'كلمة المرور',
                      '8 أحرف على الأقل',
                      3,
                      obscure: true,
                    ),
                  ] else if (step == 1) ...[
                    _field('اسم المؤسسة / المحطة', 'محطات النور للطاقة', 5),
                    const SizedBox(height: 12),
                    _field('نوع المنشأة', 'محطة شحن سيارات كهربائية', 6),
                    const SizedBox(height: 12),
                    _field('المحافظة / المدينة', 'عدن', 7),
                    const SizedBox(height: 12),
                    _field('العنوان', 'شارع المطار، خور مكسر', 8),
                    const SizedBox(height: 12),
                    _field('رقم السجل التجاري', 'سجل تجاري ساري', 9),
                    const SizedBox(height: 12),
                    _locationField(),
                  ] else ...[
                    for (var i = 0; i < 4; i++) ...[
                      DocumentUploadTile(
                        title: [
                          'صورة الهوية الشخصية',
                          'السجل التجاري',
                          'ترخيص مزاولة النشاط',
                          'إثبات ملكية / إيجار الموقع',
                        ][i],
                        fileName: files[i]?.name,
                        error: showErrors && files[i] == null,
                        onTap: () => _pickDocument(i),
                        onRemove: () => setState(() => files[i] = null),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          OwnerStickyAction(
            keyboardAware: true,
            child: OwnerButton(
              label: step == 2 ? 'متابعة' : 'التالي',
              onPressed: submitting
                  ? null
                  : () async {
                      setState(() => showErrors = true);
                      final valid = step == 2
                          ? files.every((f) => f != null)
                          : step == 0
                              ? controllers[0].text.isNotEmpty &&
                                  controllers[1].text.isNotEmpty &&
                                  controllers[3].text.length >= 6 &&
                                  location != null
                              : controllers[5].text.isNotEmpty &&
                                  controllers[7].text.isNotEmpty &&
                                  controllers[9].text.isNotEmpty;
                      if (!valid) {
                        if (step == 2 && files.any((f) => f == null)) return;
                        if (step != 2) {
                          showOwnerMessage(
                              context, 'يرجى إكمال الحقول المطلوبة بشكل صحيح');
                          return;
                        }
                      }
                      if (step < 2) {
                        setState(() {
                          step++;
                          showErrors = false;
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewSubmitScreen(
                              ownerName: controllers[0].text.trim(),
                              phone: controllers[1].text.trim(),
                              establishment: controllers[5].text.trim(),
                              city: controllers[7].text.trim(),
                              documentCount:
                                  files.whereType<PlatformFile>().length,
                              onSubmit: _createAccount,
                            ),
                          ),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createAccount() async {
    setState(() {
      submitting = true;
      duplicateAccount = false;
    });
    final profile = OwnerProfile(
      fullName: controllers[0].text.trim(),
      phone: controllers[1].text.trim(),
      email: controllers[2].text.trim(),
      establishment: controllers[5].text.trim(),
      city: controllers[7].text.trim(),
      address: controllers[8].text.trim(),
      registrationNumber: controllers[9].text.trim(),
      latitude: location?.latitude,
      longitude: location?.longitude,
    );
    final created = await store.register(
      profile: profile,
      password: controllers[3].text,
    );
    if (!mounted) return;
    setState(() {
      submitting = false;
      duplicateAccount = !created;
    });
    if (!created) {
      showOwnerMessage(context, 'البريد أو رقم الهاتف مسجل مسبقاً.');
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const StatusScreen(status: ApplicationStatus.pending),
      ),
      (route) => false,
    );
  }

  Widget _locationField() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: showErrors && location == null
                  ? Colors.red
                  : const Color(0xFFDCE4DC)),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('تحديد الموقع على الخريطة',
              textAlign: TextAlign.right, style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(
              location == null ? 'حدد موقع محطة الشحن' : 'تم تحديد موقع المحطة',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption),
          if (location != null)
            Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                    '${location!.latitude.toStringAsFixed(5)}, ${location!.longitude.toStringAsFixed(5)}',
                    textAlign: TextAlign.left)),
          OwnerButton(
            label: location == null ? 'فتح محدد الخريطة' : 'تعديل الموقع',
            outlined: true,
            icon: Icons.map_outlined,
            onPressed: _pickLocation,
          ),
        ]),
      );

  Future<void> _pickLocation() async {
    final point = await Navigator.push<ProviderMapPoint>(
        context,
        MaterialPageRoute(
            builder: (_) => ProviderMapPicker(initial: location)));
    if (point != null) setState(() => location = point);
  }

  Future<void> _pickDocument(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (!mounted || result == null || result.files.isEmpty) return;
      setState(() => files[index] = result.files.single);
    } catch (_) {
      if (mounted) {
        showOwnerMessage(context, 'تعذّر فتح منتقي الملفات. حاول مرة أخرى.');
      }
    }
  }

  Widget _field(
    String label,
    String hint,
    int index, {
    TextInputType? type,
    bool obscure = false,
  }) =>
      CustomLabeledTextField(
        label: label,
        hint: hint,
        helperText: switch (index) {
          0 => 'اكتب الاسم كما يظهر في الهوية.',
          1 => 'أدخل رقم هاتفك اليمني.',
          2 => 'سنستخدمه لتسجيل الدخول والتواصل.',
          3 => 'استخدم ٨ أحرف على الأقل.',
          _ => null,
        },
        controller: controllers[index],
        keyboardType: type,
        obscureText: obscure,
        onChanged: (_) => setState(() {}),
        errorText: showErrors && controllers[index].text.isEmpty && index != 2
            ? 'هذا الحقل مطلوب'
            : null,
      );
}
