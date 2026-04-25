import 'package:dangdang/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('food analysis result screen renders key sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DangDangApp());

    expect(find.text('\uC2DD\uB2E8 \uC0C1\uC138'), findsOneWidget);
    expect(
      find.text('\uBE44\uBE54\uBC25, \uB41C\uC7A5\uAD6D'),
      findsOneWidget,
    );
    expect(find.text('\uCD1D \uC601\uC591 \uC815\uBCF4 \uD569\uACC4'), findsOneWidget);
    expect(find.text('AI \uC2DD\uB2E8 \uBD84\uC11D'), findsOneWidget);
  });
}
