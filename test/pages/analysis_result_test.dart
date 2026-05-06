import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dangdang/screens/analysis_result.dart';

void main() {
  late XFile mockImage;

  final mockResult = {
    'foods': [
      {
        'name': '밥',
        'amount': '1공기',
        'carbohydrate': 65,
        'protein': 6,
        'fat': 1,
        'sugar': 0,
      },
      {
        'name': '김치',
        'amount': '1접시',
        'carbohydrate': 5,
        'protein': 1,
        'fat': 0,
        'sugar': 2,
      },
    ],
    'aiComment': '테스트용 분석 결과입니다.',
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
      home: AnalysisResult(result: mockResult, image: mockImage),
    );
  }

  testWidgets('분석 결과 화면 UI 렌더링', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('분석 결과'), findsOneWidget);
    expect(find.text('상세 수정 및 저장'), findsOneWidget);
    expect(find.text('다시 촬영하기'), findsOneWidget);
  });

  testWidgets('음식 리스트가 잘 표시되는지', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('인식된 음식 (2)'), findsOneWidget);
    expect(find.textContaining('밥'), findsWidgets);
    expect(find.textContaining('김치'), findsWidgets);
  });

  testWidgets('다시 촬영하기 버튼 클릭 테스트', (tester) async {
    await tester.pumpWidget(createTestWidget());

    final button = find.text('다시 촬영하기');

    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    await tester.tap(button);
    await tester.pumpAndSettle();
  });
}
