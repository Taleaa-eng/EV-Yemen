import 'package:ev_yemen/features/customer/customer_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('system back closes the rating dialog safely', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CustomerPlaceDetailScreen(title: 'ورشة اختبار', kind: 'ورشة'),
    ));
    await tester.pumpAndSettle();

    final addRating = find.text('أضف تقييماً');
    await tester.ensureVisible(addRating);
    await tester.tap(addRating);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
