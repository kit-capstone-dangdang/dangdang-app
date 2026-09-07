import 'package:dangdang/features/blood_glucose/domain/services/blood_glucose_risk_calculator.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_glucose_risk_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final sample in [
    (BloodGlucoseRiskLevel.low, '낮음', const Color(0xFF34A853)),
    (BloodGlucoseRiskLevel.moderate, '보통', const Color(0xFFEF6C00)),
    (BloodGlucoseRiskLevel.high, '높음', const Color(0xFFE53935)),
    (null, '평가 불가', Colors.grey),
  ]) {
    testWidgets('renders ${sample.$2} with its assigned color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodGlucoseRiskView(
              lowRiskLevel: sample.$1,
              highRiskLevel: sample.$1,
            ),
          ),
        ),
      );
      expect(find.text('혈당 위험'), findsOneWidget);
      expect(find.text('저혈당 위험'), findsOneWidget);
      expect(find.text('고혈당 위험'), findsOneWidget);
      expect(find.text(sample.$2), findsNWidgets(2));
      for (final text in tester.widgetList<Text>(find.text(sample.$2))) {
        expect(text.style!.color, sample.$3);
      }
      expect(find.textContaining('LBGI'), findsNothing);
      expect(find.textContaining('HBGI'), findsNothing);
    });
  }
}
