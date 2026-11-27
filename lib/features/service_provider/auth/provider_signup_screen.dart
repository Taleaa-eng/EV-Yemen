import 'package:flutter/material.dart';

import '../../../core/models/business_document.dart';
import '../../../core/services/business_approval_store.dart';
import '../../../core/services/business_document_picker.dart';
import '../../../core/services/auth_validators.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/business_approval_screen.dart';
import '../../../core/widgets/business_document_tile.dart';
import '../../../core/widgets/store_image_picker.dart';
import '../../station_owner/widgets/owner_widgets.dart';
import '../provider_local_store.dart';
import '../provider_map_picker.dart';

class ProviderSignupScreen extends StatefulWidget {
  const ProviderSignupScreen({super.key, required this.subtype});
  final String subtype;
  @override
  State<ProviderSignupScreen> createState() => _ProviderSignupScreenState();
}

class _ProviderSignupScreenState extends State<ProviderSignupScreen> {
  final fields = {
    for (final key in [
      'name',
      'phone',
      'email',
      'password',
      'business',
      'city',
      'address',
      'registration',
      'category'
    ])
      key: TextEditingController()
  };
  static const requiredDocuments = <String, String>{
    'identity': 'الهوية الشخصية',
    'commercial_register': 'السجل التجاري',
    'activity_license': 'ترخيص مزاولة النشاط',
    'premises_proof': 'إثبات ملكية / إيجار الموقع',
  };
  final Map<String, BusinessDocument> documents = {};
  final store = ProviderLocalStore.instance;
  bool errors = false;
  bool submitting = false;
  bool locationSelected = false;
  String? storeImagePath;
  double latitude = 15.3694, longitude = 44.1910;
  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('إنشاء حساب مزود خدمة'),
        centerTitle: true,
        actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('بيانات ${widget.subtype}',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 14),
            _field('الاسم الكامل', 'name', required: true),
            _field('رقم الهاتف', 'phone',
                required: true, keyboard: TextInputType.phone),
            _field('البريد الإلكتروني (اختياري)', 'email',
                keyboard: TextInputType.emailAddress),
            _field('كلمة المرور', 'password', required: true, obscure: true),
            _field(
                widget.subtype == 'صاحب ورشة'
                    ? 'اسم الورشة'
                    : 'اسم متجر قطع الغيار',
                'business',
                required: true),
            _field('المدينة / المحافظة', 'city', required: true),
            _field('العنوان التفصيلي', 'address', required: true),
            _field('رقم السجل التجاري', 'registration', required: true),
            _field(widget.subtype == 'صاحب ورشة' ? 'التخصص' : 'نوع النشاط',
                'category',
                required: true,
                hint: widget.subtype == 'صاحب ورشة'
                    ? 'صيانة عامة، بطاريات...'
                    : 'قطع غيار سيارات كهربائية'),
            const SizedBox(height: 8),
            _locationCard(),
            const SizedBox(height: 18),
            StoreImagePicker(
              onChanged: (path) => setState(() => storeImagePath = path),
              error: errors && storeImagePath == null,
            ),
            const SizedBox(height: 18),
            const Text('رفع الوثائق',
                textAlign: TextAlign.right, style: AppTextStyles.h2),
            const SizedBox(height: 8),
            for (final entry in requiredDocuments.entries) ...[
              BusinessDocumentTile(
                title: entry.value,
                instruction: switch (entry.key) {
                  'identity' => 'ارفع صورة واضحة وسارية لهوية مالك النشاط.',
                  'commercial_register' =>
                    'أرفق السجل التجاري المطابق لبيانات المنشأة.',
                  'activity_license' => 'أرفق ترخيص النشاط أو ما يثبت مزاولته.',
                  _ => 'أرفق عقد ملكية أو إيجار موقع الورشة أو المتجر.',
                },
                document: documents[entry.key],
                error: errors && !documents.containsKey(entry.key),
                onPick: () => _pickDocument(entry.key),
                onRemove: () => setState(() => documents.remove(entry.key)),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 20)
          ])),
      bottomNavigationBar: OwnerStickyAction(
          keyboardAware: true,
          child: OwnerButton(
              label: submitting ? 'جارٍ إنشاء الحساب...' : 'إنشاء حساب',
              onPressed: submitting ? null : _submit)));

  Widget _field(String label, String key,
          {bool required = false,
          bool obscure = false,
          TextInputType? keyboard,
          String? hint}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Directionality(
              textDirection:
                  key == 'phone' ? TextDirection.ltr : TextDirection.rtl,
              child: obscure
                  ? OwnerPasswordField(
                      label: label,
                      hint: hint,
                      controller: fields[key],
                      errorText: errors &&
                              key == 'phone' &&
                              !isValidYemenPhone(fields[key]!.text)
                          ? 'أدخل رقم هاتف يمني صالحاً'
                          : errors &&
                                  key == 'password' &&
                                  !isValidPassword(fields[key]!.text)
                              ? 'كلمة المرور يجب أن تتكون من 8 أحرف على الأقل'
                              : errors &&
                                      required &&
                                      fields[key]!.text.trim().isEmpty
                                  ? 'هذا الحقل مطلوب'
                                  : null,
                      onChanged: (_) => setState(() {}),
                    )
                  : CustomLabeledTextField(
                      label: label,
                      hint:
                          hint ?? (key == 'phone' ? '+967 7XX XXX XXX' : null),
                      controller: fields[key],
                      keyboardType: keyboard,
                      textDirection: key == 'phone' ? TextDirection.ltr : null,
                      textAlign:
                          key == 'phone' ? TextAlign.left : TextAlign.right,
                      errorText: errors &&
                              key == 'phone' &&
                              !isValidYemenPhone(fields[key]!.text)
                          ? 'أدخل رقم هاتف يمني صالحاً'
                          : errors &&
                                  required &&
                                  fields[key]!.text.trim().isEmpty
                              ? 'هذا الحقل مطلوب'
                              : null,
                      onChanged: (_) => setState(() {}))));
  Widget _locationCard() => AppCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('تحديد الموقع على الخريطة',
            textAlign: TextAlign.right, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Text(
            locationSelected
                ? 'تم تحديد موقع المنشأة'
                : 'اختر موقع الورشة أو المتجر بدقة',
            textAlign: TextAlign.right,
            style: AppTextStyles.caption),
        if (locationSelected)
          Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                  '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
                  textAlign: TextAlign.left,
                  style: AppTextStyles.bodyMedium)),
        const SizedBox(height: 8),
        OwnerButton(
            label: locationSelected ? 'تعديل الموقع' : 'فتح محدد الخريطة',
            outlined: true,
            icon: Icons.map_outlined,
            onPressed: _chooseLocation)
      ]));
  Future<void> _chooseLocation() async {
    final point = await Navigator.push<ProviderMapPoint>(
        context,
        MaterialPageRoute(
            builder: (_) => ProviderMapPicker(
                initial: locationSelected
                    ? ProviderMapPoint(latitude, longitude)
                    : null)));
    if (point != null) {
      setState(() {
        latitude = point.latitude;
        longitude = point.longitude;
        locationSelected = true;
      });
    }
  }

  Future<void> _pickDocument(String key) async {
    try {
      final approvalKey = widget.subtype == 'صاحب قطع غيار'
          ? 'parts_provider'
          : 'workshop_owner';
      final document = await BusinessDocumentPicker.pick(folder: approvalKey);
      if (document != null && mounted) {
        setState(() => documents[key] = document);
      }
    } on BusinessDocumentPickerException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذّر فتح منتقي الملفات.')));
      }
    }
  }

  Future<void> _submit() async {
    setState(() => errors = true);
    if (fields['name']!.text.trim().isEmpty ||
        !isValidYemenPhone(fields['phone']!.text) ||
        !isValidPassword(fields['password']!.text) ||
        fields['business']!.text.trim().isEmpty ||
        fields['city']!.text.trim().isEmpty ||
        fields['address']!.text.trim().isEmpty ||
        fields['registration']!.text.trim().isEmpty ||
        fields['category']!.text.trim().isEmpty ||
        requiredDocuments.keys.any((key) => !documents.containsKey(key)) ||
        storeImagePath == null ||
        !locationSelected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'يرجى إكمال البيانات المطلوبة ورفع الوثائق وتحديد الموقع.')));
      return;
    }
    setState(() => submitting = true);
    await store.load(widget.subtype);
    await store.saveProfile({
      for (final entry in fields.entries)
        if (entry.key != 'password') entry.key: entry.value.text.trim(),
      'storeImagePath': storeImagePath!,
    });
    await store.saveDocuments(documents);
    await store.saveCredentials(
        phone: fields['phone']!.text, password: fields['password']!.text);
    await store.setLocation(latitude, longitude);
    await store.setAvailable(true);
    final approvalKey =
        widget.subtype == 'صاحب قطع غيار' ? 'parts_provider' : 'workshop_owner';
    await BusinessApprovalStore.instance.submitForReview(approvalKey);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
            builder: (_) => BusinessApprovalScreen(
                businessKey: approvalKey, businessTitle: widget.subtype)),
        (route) => route.isFirst);
  }
}
