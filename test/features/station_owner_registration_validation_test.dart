import 'package:ev_yemen/features/service_provider/provider_map_picker.dart';
import 'package:ev_yemen/features/station_owner/screens/auth/registration_screen.dart';
import 'package:ev_yemen/features/station_owner/widgets/owner_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('valid station owner details advance without a false error',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'أحمد محمد');
    await tester.enterText(find.byType(TextField).at(1), '+967 771234567');
    await tester.enterText(find.byType(TextField).at(3), 'password123');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('بيانات المنشأة'), findsWidgets);

    await tester.enterText(find.byType(TextField).at(0), 'محطات النور');
    await tester.enterText(
        find.byType(TextField).at(1), 'محطة شحن سيارات كهربائية');
    await tester.enterText(find.byType(TextField).at(2), 'عدن');
    await tester.enterText(find.byType(TextField).at(3), 'خور مكسر');
    await tester.enterText(find.byType(TextField).at(4), 'CR-12345');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('فتح محدد الخريطة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('فتح محدد الخريطة'));
    await tester.pumpAndSettle();
    expect(find.byType(ProviderMapPicker), findsOneWidget);
    await tester.tap(find.text('تأكيد الموقع'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    expect(find.text('الوثائق'), findsWidgets);
    expect(find.text('يرجى إكمال الحقول المطلوبة بشكل صحيح'), findsNothing);
  });

  testWidgets('password visibility toggle reveals and hides its own field',
      (tester) async {
    final controller = TextEditingController(text: 'password123');
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OwnerPasswordField(
          label: 'كلمة المرور',
          controller: controller,
        ),
      ),
    ));

    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();
    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue);
  });
}
