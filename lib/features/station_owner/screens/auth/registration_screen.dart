import 'package:flutter/material.dart';
import '../../../../core/models/business_document.dart';
import '../../../../core/services/auth_validators.dart';
import '../../../../core/services/business_document_picker.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/business_document_tile.dart';
import '../../../../core/widgets/store_image_picker.dart';
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
  late final Future<void> _storeReady;
  StationOwnerLocalStore get store =>
      widget.store ?? StationOwnerLocalStore.instance;
  final controllers = List.generate(10, (_) => TextEditingController());
  static const requiredDocuments = <String, String>{
    'identity': 'صورة الهوية الشخصية',
    'commercial_register': 'السجل التجاري',
    'activity_license': 'ترخيص تشغيل محطة الشحن',
    'premises_proof': 'إثبات ملكية / إيجار الموقع',
  };
  final Map<String, BusinessDocument> documents = {};
  ProviderMapPoint? location;
  String? storeImagePath;
  @override
  void initState() {
    super.initState();
    step = widget.initialStep;
    _storeReady = store.initialize();
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
                  if (step == 1)
                    Text('بيانات متجر / محطة ${controllers[5].text}'.trim(),
                        textAlign: TextAlign.right,
                        style: AppTextStyles.caption),
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
                    const SizedBox(height: 12),
                    StoreImagePicker(
                      onChanged: (path) =>
                          setState(() => storeImagePath = path),
                      error: showErrors && storeImagePath == null,
                    ),
                  ] else ...[
                    for (final entry in requiredDocuments.entries) ...[
                      BusinessDocumentTile(
                        title: entry.value,
                        instruction: switch (entry.key) {
                          'identity' =>
                            'ارفع صورة واضحة وسارية لهوية مالك المحطة.',
                          'commercial_register' =>
                            'أرفق السجل التجاري المطابق لبيانات المنشأة.',
                          'activity_license' =>
                            'أرفق ترخيص تشغيل محطة شحن المركبات الكهربائية.',
                          _ => 'أرفق عقد الملكية أو الإيجار للموقع.',
                        },
                        document: documents[entry.key],
                        error: showErrors && !documents.containsKey(entry.key),
                        onPick: () => _pickDocument(entry.key),
                        onRemove: () =>
                            setState(() => documents.remove(entry.key)),
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
                          ? requiredDocuments.keys.every(documents.containsKey)
                          : step == 0
                              ? controllers[0].text.trim().isNotEmpty &&
                                  isValidYemenPhone(controllers[1].text) &&
                                  isValidPassword(controllers[3].text)
                              : controllers[5].text.trim().isNotEmpty &&
                                  controllers[6].text.trim().isNotEmpty &&
                                  controllers[7].text.trim().isNotEmpty &&
                                  controllers[8].text.trim().isNotEmpty &&
                                  controllers[9].text.trim().isNotEmpty &&
                                  location != null &&
                                  storeImagePath != null;
                      if (!valid) {
                        if (step == 2 &&
                            requiredDocuments.keys
                                .any((key) => !documents.containsKey(key))) {
                          return;
                        }
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
                              documentCount: documents.length,
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
    await _storeReady;
    if (!mounted) return;
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
      storeImagePath: storeImagePath,
    );
    final created = await store.register(
      profile: profile,
      password: controllers[3].text,
      documents: documents,
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

  Future<void> _pickDocument(String key) async {
    try {
      final document =
          await BusinessDocumentPicker.pick(folder: 'station_owner');
      if (mounted && document != null) {
        setState(() => documents[key] = document);
      }
    } on BusinessDocumentPickerException catch (error) {
      if (mounted) showOwnerMessage(context, error.message);
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
  }) {
    final errorText = showErrors &&
            index == 1 &&
            !isValidYemenPhone(controllers[index].text)
        ? 'أدخل رقم هاتف يمني صالحاً'
        : showErrors && index == 3 && !isValidPassword(controllers[index].text)
            ? 'كلمة المرور يجب أن تتكون من 8 أحرف على الأقل'
            : showErrors && controllers[index].text.trim().isEmpty && index != 2
                ? 'هذا الحقل مطلوب'
                : null;
    if (obscure) {
      return OwnerPasswordField(
        label: label,
        hint: hint,
        helperText: switch (index) {
          0 => 'اكتب الاسم كما يظهر في الهوية.',
          1 => 'أدخل رقم هاتفك اليمني.',
          2 => 'سنستخدمه لتسجيل الدخول والتواصل.',
          3 => 'استخدم 8 أحرف على الأقل.',
          _ => null,
        },
        controller: controllers[index],
        errorText: errorText,
        onChanged: (_) => setState(() {}),
      );
    }
    return CustomLabeledTextField(
      label: label,
      hint: hint,
      helperText: switch (index) {
        0 => 'اكتب الاسم كما يظهر في الهوية.',
        1 => 'أدخل رقم هاتفك اليمني.',
        2 => 'سنستخدمه لتسجيل الدخول والتواصل.',
        _ => null,
      },
      controller: controllers[index],
      keyboardType: type,
      onChanged: (_) => setState(() {}),
      errorText: errorText,
    );
  }
}
