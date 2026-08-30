import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diasense_mobile/core/widgets/risk_gauge.dart';

void main() {
  testWidgets('RiskGauge displays percentage and category correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RiskGauge(
            riskPercentage: 75.0,
            riskCategory: 'High Risk',
          ),
        ),
      ),
    );

    expect(find.text('75%'), findsOneWidget);
    expect(find.text('HIGH RISK'), findsOneWidget);
  });
}
