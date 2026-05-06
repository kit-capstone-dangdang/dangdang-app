// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:dangdang/screens/meal_record_page.dart';

// void main() {
//   testWidgets('식단 기록 화면 UI', (tester) async {
//     await tester.pumpWidget(const MaterialApp(home: MealRecordPage()));

//     expect(find.text('식단 기록'), findsOneWidget);
//     expect(find.text('2026.03.26'), findsOneWidget);

//     expect(find.text('점심'), findsOneWidget);
//     expect(find.text('12:30'), findsOneWidget);
//     expect(find.text('605 kcal'), findsOneWidget);
//     expect(find.text('비빔밥, 된장국'), findsOneWidget);
//     expect(find.text('2개 품목'), findsOneWidget);
//     expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
//     expect(find.byIcon(Icons.delete_outlined), findsNWidgets(2));

//     expect(find.text('저녁'), findsOneWidget);
//     expect(find.text('18:30'), findsOneWidget);
//     expect(find.text('532 kcal'), findsOneWidget);
//     expect(find.text('아보카도 비빔밥, 오이무침, 김자반'), findsOneWidget);
//     expect(find.text('3개 품목'), findsOneWidget);

//     expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
//   });

//   testWidgets('식단 카드를 누르면 식단 상세 화면으로 이동', (tester) async {
//     await tester.pumpWidget(const MaterialApp(home: MealRecordPage()));

//     await tester.tap(find.text('비빔밥, 된장국'));
//     await tester.pumpAndSettle();

//     expect(find.text('식단 상세'), findsOneWidget);
//     expect(find.text('총 영양 정보 합계'), findsOneWidget);
//     expect(find.text('상세 품목 (2)'), findsOneWidget);
//     expect(find.text('AI 식단 분석'), findsOneWidget);
//     expect(find.text('목록으로 돌아가기'), findsOneWidget);
//   });

//   testWidgets('식단 상세 화면에서 목록으로 돌아가기 버튼 누르면 식단 기록 화면으로 이동', (tester) async {
//     await tester.pumpWidget(const MaterialApp(home: MealRecordPage()));

//     await tester.tap(find.text('비빔밥, 된장국'));
//     await tester.pumpAndSettle();

//     expect(find.text('식단 상세'), findsOneWidget);

//     await tester.ensureVisible(find.text('목록으로 돌아가기'));
//     await tester.pumpAndSettle();

//     await tester.tap(find.text('목록으로 돌아가기'));
//     await tester.pumpAndSettle();

//     expect(find.text('식단 기록'), findsOneWidget);
//     expect(find.text('식단 상세'), findsNothing);
//   });
// }
