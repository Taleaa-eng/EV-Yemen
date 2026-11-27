import 'package:flutter/material.dart';

import '../../core/services/auth_validators.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/store_image_picker.dart';
import '../station_owner/widgets/owner_widgets.dart';
import 'dealer_document_upload_screen.dart';

class DealerSignupScreen extends StatefulWidget {
  const DealerSignupScreen({super.key});

  @override
  State<DealerSignupScreen> createState() => _DealerSignupScreenState();
}

class _DealerSignupScreenState extends State<DealerSignupScreen> {
  final _name = TextEditingController();
  final _registration = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  String? _storeImagePath;
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _registration.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _continueToDocuments() async {
    setState(() => _submitted = true);
    if (_name.text.trim().isEmpty ||
        _registration.text.trim().isEmpty ||
        !isValidYemenPhone(_phone.text) ||
        _address.text.trim().isEmpty ||
        !isValidPassword(_password.text) ||
        _storeImagePath == null) {
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DealerDocumentUploadScreen.registration(
          profile: {
            'name': _name.text.trim(),
            'registration': _registration.text.trim(),
            'phone': _phone.text.trim(),
            'email': _email.text.trim(),
            'address': _address.text.trim(),
            'storeImagePath': _storeImagePath!,
          },
          password: _password.text,
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType? keyboardType,
      bool ltr = false,
      bool required = true,
      bool password = false,
      String? error}) {
    final field = password
        ? OwnerPasswordField(
            label: label,
            controller: controller,
            errorText: error,
            helperText: '8 أحرف على الأقل',
            onChanged: (_) => setState(() {}),
          )
        : CustomLabeledTextField(
            label: label,
            controller: controller,
            keyboardType: keyboardType,
            textDirection: ltr ? TextDirection.ltr : null,
            textAlign: ltr ? TextAlign.left : TextAlign.right,
            errorText: error,
            onChanged: (_) => setState(() {}),
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: field,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('إنشاء حساب وكيل سيارات'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          children: [
            const Text('بيانات الوكيل / المعرض',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 14),
            _field('اسم المعرض', _name,
                error: _submitted && _name.text.trim().isEmpty
                    ? 'أدخل اسم المعرض'
                    : null),
            _field('رقم السجل التجاري', _registration,
                ltr: true,
                error: _submitted && _registration.text.trim().isEmpty
                    ? 'أدخل رقم السجل التجاري'
                    : null),
            _field('رقم الهاتف', _phone,
                ltr: true,
                keyboardType: TextInputType.phone,
                error: _submitted && !isValidYemenPhone(_phone.text)
                    ? 'أدخل رقم هاتف يمني صالحاً'
                    : null),
            _field('البريد الإلكتروني (اختياري)', _email,
                required: false,
                ltr: true,
                keyboardType: TextInputType.emailAddress),
            _field('العنوان', _address,
                error: _submitted && _address.text.trim().isEmpty
                    ? 'أدخل عنوان المعرض'
                    : null),
            _field('كلمة المرور', _password,
                password: true,
                error: _submitted && !isValidPassword(_password.text)
                    ? 'كلمة المرور يجب أن تتكون من 8 أحرف على الأقل'
                    : null),
            const SizedBox(height: 4),
            StoreImagePicker(
              onChanged: (path) => setState(() => _storeImagePath = path),
              error: _submitted && _storeImagePath == null,
            ),
          ],
        ),
        bottomNavigationBar: OwnerStickyAction(
          keyboardAware: true,
          child: AppButton(
            label: 'التالي: رفع الوثائق',
            onPressed: _continueToDocuments,
          ),
        ),
      );
}
