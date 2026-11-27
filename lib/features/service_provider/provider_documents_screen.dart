import 'package:flutter/material.dart';

import '../../core/models/business_document.dart';
import '../../core/services/business_document_picker.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/business_document_tile.dart';
import '../station_owner/widgets/owner_widgets.dart';
import 'provider_local_store.dart';

class ProviderDocumentsScreen extends StatefulWidget {
  const ProviderDocumentsScreen({super.key, required this.subtype});
  final String subtype;

  @override
  State<ProviderDocumentsScreen> createState() =>
      _ProviderDocumentsScreenState();
}

class _ProviderDocumentsScreenState extends State<ProviderDocumentsScreen> {
  static const documentsRequired = <String, String>{
    'identity': 'الهوية الشخصية',
    'commercial_register': 'السجل التجاري',
    'activity_license': 'ترخيص مزاولة النشاط',
    'premises_proof': 'إثبات ملكية / إيجار الموقع',
  };

  final _store = ProviderLocalStore.instance;
  late final Map<String, BusinessDocument> _documents =
      Map.of(_store.documents);
  bool _showErrors = false;
  bool _saving = false;

  Future<void> _pick(String key) async {
    try {
      final folder = widget.subtype == 'صاحب قطع غيار'
          ? 'parts_provider'
          : 'workshop_owner';
      final document = await BusinessDocumentPicker.pick(folder: folder);
      if (!mounted || document == null) return;
      setState(() => _documents[key] = document);
    } on BusinessDocumentPickerException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر فتح منتقي الملفات.')),
        );
      }
    }
  }

  Future<void> _save() async {
    setState(() => _showErrors = true);
    if (documentsRequired.keys.any((key) => !_documents.containsKey(key))) {
      return;
    }
    setState(() => _saving = true);
    await _store.saveDocuments(_documents);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('الوثائق والمتطلبات'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text('وثائق ${widget.subtype}',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 6),
            const Text(
              'تأكد من وضوح المستندات وسريانها. الصيغ المقبولة PDF أو PNG أو JPG، بحد أقصى 5 MB لكل ملف.',
              textAlign: TextAlign.right,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            for (final entry in documentsRequired.entries) ...[
              BusinessDocumentTile(
                title: entry.value,
                instruction: switch (entry.key) {
                  'identity' => 'هوية مالك النشاط أو المفوض عنه.',
                  'commercial_register' =>
                    'السجل التجاري المطابق لبيانات الحساب.',
                  'activity_license' => 'ترخيص الورشة أو نشاط بيع قطع الغيار.',
                  _ => 'عقد ملكية أو إيجار موقع النشاط.',
                },
                document: _documents[entry.key],
                error: _showErrors && !_documents.containsKey(entry.key),
                onPick: () => _pick(entry.key),
                onRemove: () => setState(() => _documents.remove(entry.key)),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
        bottomNavigationBar: OwnerStickyAction(
          keyboardAware: true,
          child: OwnerButton(
            label: _saving ? 'جارٍ الحفظ…' : 'حفظ الوثائق',
            onPressed: _saving ? null : _save,
          ),
        ),
      );
}
