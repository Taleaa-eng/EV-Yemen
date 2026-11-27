import 'package:flutter/material.dart';

import '../../core/models/business_document.dart';
import '../../core/services/business_approval_store.dart';
import '../../core/services/business_document_picker.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/business_approval_screen.dart';
import '../../core/widgets/business_document_tile.dart';
import '../station_owner/widgets/owner_widgets.dart';
import 'dealer_local_store.dart';

class DealerDocumentUploadScreen extends StatefulWidget {
  const DealerDocumentUploadScreen.registration({
    super.key,
    required this.profile,
    required this.password,
  }) : isRegistration = true;

  const DealerDocumentUploadScreen.profile({super.key})
      : isRegistration = false,
        profile = null,
        password = null;

  final bool isRegistration;
  final Map<String, String>? profile;
  final String? password;

  @override
  State<DealerDocumentUploadScreen> createState() =>
      _DealerDocumentUploadScreenState();
}

class _DealerDocumentUploadScreenState
    extends State<DealerDocumentUploadScreen> {
  static const _documentTitles = <String, String>{
    'identity': 'صورة الهوية الشخصية',
    'commercial_register': 'السجل التجاري',
    'agency_license': 'ترخيص أو تفويض الوكالة',
    'premises_proof': 'إثبات ملكية أو إيجار المعرض',
  };

  final Map<String, BusinessDocument> _documents = {};
  final Set<String> _invalidFiles = {};
  bool _showErrors = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _documents.addAll(DealerLocalStore.instance.documents);
  }

  Future<void> _pickDocument(String key) async {
    try {
      final document = await BusinessDocumentPicker.pick(folder: 'car_dealer');
      if (!mounted || document == null) return;
      setState(() {
        _invalidFiles.remove(key);
        _documents[key] = document;
      });
    } on BusinessDocumentPickerException catch (error) {
      if (!mounted) return;
      setState(() => _invalidFiles.add(key));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _invalidFiles.add(key));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر فتح منتقي الملفات.')),
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _showErrors = true);
    final allPresent = _documentTitles.keys.every(_documents.containsKey);
    if (!allPresent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إرفاق جميع الوثائق المطلوبة')),
      );
      return;
    }

    setState(() => _busy = true);
    final store = DealerLocalStore.instance;
    if (widget.isRegistration) {
      final profile = widget.profile!;
      final result = await store.register(
        phone: profile['phone'] ?? '',
        password: widget.password ?? '',
        profile: profile,
        documents: _documents,
      );
      if (!mounted) return;
      if (result != DealerRegistrationResult.created) {
        setState(() => _busy = false);
        final message = switch (result) {
          DealerRegistrationResult.invalidDetails =>
            'تحقق من رقم الهاتف وكلمة المرور ثم أعد المحاولة.',
          DealerRegistrationResult.missingDocuments =>
            'يرجى إرفاق جميع الوثائق المطلوبة.',
          DealerRegistrationResult.accountAlreadyExists =>
            'يوجد حساب وكيل مسجل بالفعل. سجّل الدخول باستخدام رقم الهاتف.',
          DealerRegistrationResult.storageFailure =>
            'تعذّر حفظ بيانات الحساب على هذا الجهاز. أعد المحاولة.',
          DealerRegistrationResult.created => '',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }
      await BusinessApprovalStore.instance.submitForReview('car_dealer');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const BusinessApprovalScreen(
            businessKey: 'car_dealer',
            businessTitle: 'وكيل السيارات',
          ),
        ),
        (route) => route.isFirst,
      );
      return;
    }

    await store.saveDocuments(_documents);
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final uploadedCount =
        _documentTitles.keys.where(_documents.containsKey).length;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title:
              Text(widget.isRegistration ? 'رفع وثائق الوكيل' : 'وثائق الوكيل'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          children: [
            const Text('الوثائق المطلوبة',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 6),
            const Text(
              'أرفق المستندات الأربعة للتحقق من بيانات معرض السيارات وإكمال التسجيل.',
              textAlign: TextAlign.right,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'المرفق $uploadedCount من ${_documentTitles.length}',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: uploadedCount / _documentTitles.length,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE8F5E9),
                      color: const Color(0xFF1B5F51),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'كل الملفات مطلوبة لإرسال الطلب للمراجعة.',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final entry in _documentTitles.entries) ...[
              BusinessDocumentTile(
                title: entry.value,
                instruction: switch (entry.key) {
                  'identity' => 'ارفع صورة واضحة وسارية لهوية مالك المعرض.',
                  'commercial_register' =>
                    'أرفق السجل التجاري المطابق لبيانات المعرض.',
                  'agency_license' =>
                    'أرفق تفويض الوكالة أو ترخيص استيراد وبيع المركبات.',
                  _ => 'أرفق عقد ملكية أو إيجار موقع المعرض.',
                },
                document: _documents[entry.key],
                error: (_showErrors && !_documents.containsKey(entry.key)) ||
                    _invalidFiles.contains(entry.key),
                onPick: () => _pickDocument(entry.key),
                onRemove: () => setState(() {
                  _documents.remove(entry.key);
                  _invalidFiles.remove(entry.key);
                }),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            const Text(
              'الصيغ المقبولة: PDF، PNG، JPG • الحد الأقصى 5 MB لكل ملف',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption,
            ),
          ],
        ),
        bottomNavigationBar: OwnerStickyAction(
          keyboardAware: true,
          child: AppButton(
            label: _busy
                ? 'جارٍ الحفظ…'
                : widget.isRegistration
                    ? 'إنشاء حساب'
                    : 'حفظ الوثائق',
            onPressed: _busy ? null : _submit,
          ),
        ),
      );
  }
}
