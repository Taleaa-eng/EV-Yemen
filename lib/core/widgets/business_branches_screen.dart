import 'dart:io';

import 'package:flutter/material.dart';

import '../models/business_branch.dart';
import '../models/business_document.dart';
import '../services/business_branch_store.dart';
import '../services/auth_validators.dart';
import '../services/business_document_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_shared_components.dart';
import 'business_document_tile.dart';
import '../../features/station_owner/widgets/owner_widgets.dart'
    show CustomLabeledTextField;
import 'store_image_picker.dart';

class BusinessBranchesScreen extends StatefulWidget {
  const BusinessBranchesScreen({
    super.key,
    required this.businessKey,
    required this.title,
  });

  final String businessKey;
  final String title;

  @override
  State<BusinessBranchesScreen> createState() => _BusinessBranchesScreenState();
}

class _BusinessBranchesScreenState extends State<BusinessBranchesScreen> {
  final _store = BusinessBranchStore.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _store.load(widget.businessKey);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addBranch() async {
    final branch = await Navigator.push<BusinessBranch>(
      context,
      MaterialPageRoute<BusinessBranch>(
        builder: (_) => AddBusinessBranchScreen(title: widget.title),
      ),
    );
    if (branch != null) await _store.save(widget.businessKey, branch);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('إدارة الفروع'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'رجوع',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _store,
          builder: (context, _) {
            final branches = _store.branchesFor(widget.businessKey);
            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              children: [
                const Text('الفروع',
                    textAlign: TextAlign.right, style: AppTextStyles.h1),
                const SizedBox(height: 6),
                Text('إدارة فروع ${widget.title} ومواقعها وبيانات التحقق.',
                    textAlign: TextAlign.right, style: AppTextStyles.body),
                const SizedBox(height: 16),
                AppButton(
                  label: 'إضافة فرع جديد',
                  icon: Icons.add_rounded,
                  onPressed: _addBranch,
                ),
                const SizedBox(height: 16),
                if (branches.isEmpty)
                  const AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.store_mall_directory_outlined,
                            size: 36, color: AppColors.brand),
                        SizedBox(height: 8),
                        Text('لا توجد فروع مضافة',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.h3),
                        Text('أضف فرعاً لعرضه هنا بعد إرساله للمراجعة.',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                for (final branch in branches) ...[
                  _BranchCard(branch: branch),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      );
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});
  final BusinessBranch branch;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (branch.imagePath.isNotEmpty &&
                File(branch.imagePath).existsSync())
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.file(
                  File(branch.imagePath),
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AppStatusBadge(
                        branch.approved ? 'معتمد' : 'قيد مراجعة الأدمن',
                        tone: branch.approved
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(branch.name,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${branch.city} • ${branch.address}',
                      textAlign: TextAlign.right, style: AppTextStyles.body),
                  Text(
                      'السجل التجاري: ${branch.commercialRegistrationNumber} • الترخيص: ${branch.licenseNumber}',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${branch.latitude.toStringAsFixed(5)}, ${branch.longitude.toStringAsFixed(5)}  •  ${branch.phone}',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.caption,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('الوثائق المرفقة: ${branch.documents.length}',
                      textAlign: TextAlign.right, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      );
}

class AddBusinessBranchScreen extends StatefulWidget {
  const AddBusinessBranchScreen({super.key, required this.title});
  final String title;

  @override
  State<AddBusinessBranchScreen> createState() =>
      _AddBusinessBranchScreenState();
}

class _AddBusinessBranchScreenState extends State<AddBusinessBranchScreen> {
  static const requiredDocuments = <String, String>{
    'identity': 'هوية المسؤول عن الفرع',
    'commercial_register': 'نسخة السجل التجاري',
    'activity_license': 'ترخيص مزاولة النشاط في الفرع',
    'premises_proof': 'إثبات ملكية / إيجار الموقع',
  };

  final _name = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _registration = TextEditingController();
  final _license = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  String? _imagePath;
  final Map<String, BusinessDocument> _documents = {};
  bool _errors = false;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _address.dispose();
    _phone.dispose();
    _registration.dispose();
    _license.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(String key) async {
    try {
      final document = await BusinessDocumentPicker.pick(
        folder: 'branch_${widget.title}',
      );
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

  void _save() {
    setState(() => _errors = true);
    final latitude = double.tryParse(_latitude.text.trim());
    final longitude = double.tryParse(_longitude.text.trim());
    if (_name.text.trim().isEmpty ||
        _city.text.trim().isEmpty ||
        _address.text.trim().isEmpty ||
        !isValidYemenPhone(_phone.text) ||
        _registration.text.trim().isEmpty ||
        _license.text.trim().isEmpty ||
        latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180 ||
        requiredDocuments.keys.any((key) => !_documents.containsKey(key)) ||
        _imagePath == null) {
      return;
    }
    final firstDocument = _documents.values.first;
    Navigator.pop(
      context,
      BusinessBranch(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        city: _city.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim(),
        commercialRegistrationNumber: _registration.text.trim(),
        licenseNumber: _license.text.trim(),
        latitude: latitude,
        longitude: longitude,
        documentPath: firstDocument.path,
        documentName: firstDocument.name,
        imagePath: _imagePath!,
        documents: Map.of(_documents),
      ),
    );
  }

  String? _requiredError(TextEditingController field) =>
      _errors && field.text.trim().isEmpty ? 'هذا الحقل مطلوب' : null;

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('إضافة فرع'),
          actions: [
            IconButton(
                tooltip: 'رجوع',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded)),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          children: [
            Text('بيانات فرع ${widget.title}',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 14),
            _field('اسم الفرع', _name),
            _field('المحافظة / المدينة', _city),
            _field('العنوان التفصيلي', _address),
            Directionality(
              textDirection: TextDirection.ltr,
              child: _field('رقم التواصل', _phone,
                  keyboard: TextInputType.phone, ltr: true),
            ),
            _field('رقم السجل التجاري للفرع', _registration, ltr: true),
            _field('رقم الترخيص', _license, ltr: true),
            const SizedBox(height: 6),
            const Text('إحداثيات الموقع (GPS)',
                textAlign: TextAlign.right, style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _field('خط الطول', _longitude,
                      keyboard: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      ltr: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field('خط العرض', _latitude,
                      keyboard: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      ltr: true),
                ),
              ],
            ),
            if (_errors &&
                (double.tryParse(_latitude.text) == null ||
                    double.tryParse(_longitude.text) == null))
              const Text('أدخل إحداثيات GPS صحيحة',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: AppColors.error)),
            const SizedBox(height: 8),
            StoreImagePicker(
              onChanged: (value) => setState(() => _imagePath = value),
              error: _errors && _imagePath == null,
            ),
            const SizedBox(height: 16),
            const Text('الوثائق والمتطلبات',
                textAlign: TextAlign.right, style: AppTextStyles.h2),
            const SizedBox(height: 8),
            for (final entry in requiredDocuments.entries) ...[
              BusinessDocumentTile(
                title: entry.value,
                instruction: 'أرفق مستنداً واضحاً وسارياً لهذا الفرع.',
                document: _documents[entry.key],
                error: _errors && !_documents.containsKey(entry.key),
                onPick: () => _pickDocument(entry.key),
                onRemove: () => setState(() => _documents.remove(entry.key)),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 20),
            AppButton(label: 'حفظ الفرع وإرساله للمراجعة', onPressed: _save),
          ],
        ),
      );

  Widget _field(String label, TextEditingController controller,
          {TextInputType? keyboard, bool ltr = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CustomLabeledTextField(
          label: label,
          controller: controller,
          keyboardType: keyboard,
          textDirection: ltr ? TextDirection.ltr : null,
          textAlign: ltr ? TextAlign.left : TextAlign.right,
          errorText: controller == _phone && _errors
              ? isValidYemenPhone(controller.text)
                  ? null
                  : 'أدخل رقم هاتف يمني صالحاً'
              : _requiredError(controller),
        ),
      );
}
