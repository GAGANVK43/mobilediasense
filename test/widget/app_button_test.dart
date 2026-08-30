import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diasense_mobile/core/widgets/app_button.dart';

void main() {
  testWidgets('AppButton triggers onPressed callback and shows text', (WidgetTester tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: 'Submit Health Assessment',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Submit Health Assessment'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, isTrue);
  });
}
