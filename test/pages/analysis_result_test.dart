import 'dart:convert';
import 'dart:io';

import 'package:dangdang/core/presentation/widgets/common/custom_card.dart';
import 'package:dangdang/features/meal/presentation/views/analysis_result_page.dart';
import 'package:dangdang/features/meal/presentation/widgets/food_detail_item_card.dart';
import 'package:dangdang/features/meal/presentation/widgets/meal_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  late XFile mockImage;

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

  setUpAll(() async {
    const base64Image =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';

    final file = File('${Directory.systemTemp.path}/test_food_image.png');
    await file.writeAsBytes(base64Decode(base64Image));

    mockImage = XFile(file.path);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: AnalysisResultPage(result: mockResult, image: mockImage),
    );
  }

  testWidgets('AnalysisResultPage renders core sections', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(MealImageViewer), findsOneWidget);
    expect(find.byType(FoodDetailItemCard), findsNWidgets(2));
    expect(find.byType(CustomCard), findsNWidgets(2));
  });

  testWidgets('AnalysisResultPage shows parsed food names', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Kimchi'), findsOneWidget);
  });
}
