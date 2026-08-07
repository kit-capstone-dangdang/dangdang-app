import 'package:dangdang/features/meal/presentation/pages/analysis_result_page.dart';
import 'package:dangdang/features/meal/presentation/widgets/food_detail_item_card.dart';
import 'package:dangdang/features/meal/presentation/widgets/meal_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mockResult = {
    'foods': [
      {
        'name': 'Rice',
        'amountLabel': '1 bowl',
        'servingCount': 1,
        'calories': 300,
        'carbohydrate': 65,
        'protein': 6,
        'fat': 1,
        'sugar': 0,
      },
      {
        'name': 'Kimchi',
        'amountLabel': '1 plate',
        'servingCount': 1,
        'calories': 20,
        'carbohydrate': 5,
        'protein': 1,
        'fat': 0,
        'sugar': 2,
      },
    ],
    'aiComment': 'Test analysis result',
  };

  Widget createTestWidget() {
    return MaterialApp(
      home: AnalysisResultPage(result: mockResult, image: null),
    );
  }

  testWidgets('AnalysisResultPage renders core sections', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.byType(MealImageViewer), findsOneWidget);
    expect(find.byType(FoodDetailItemCard), findsNWidgets(2));
    expect(find.byIcon(Icons.fastfood), findsOneWidget);
  });

  testWidgets('AnalysisResultPage shows parsed food names', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Kimchi'), findsOneWidget);
  });
}
