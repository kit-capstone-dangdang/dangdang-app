import 'package:dangdang/core/presentation/widgets/common/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmptyStateView renders message and inbox icon', (
    WidgetTester tester,
  ) async {
    const message = 'No meal records yet.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EmptyStateView(message: message)),
      ),
    );

    expect(find.text(message), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('ErrorMessageView renders and retry callback is invoked', (
    WidgetTester tester,
  ) async {
    var isButtonClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorMessageView(
            errorMessage: 'Server connection failed',
            onRetry: () {
              isButtonClicked = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Server connection failed'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(isButtonClicked, isTrue);
  });
}
