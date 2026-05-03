import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 🚨 주의: 아래 경로는 실제 본인이 파일(1번 코드)을 저장한 위치로 바꿔주세요!
import 'package:dangdang/widgets/common/state_views.dart';

void main() {
  // 테스트 1: 빈 화면(EmptyStateView)이 화면에 잘 그려지는지(렌더링) 확인
  testWidgets('EmptyStateView가 텍스트와 아이콘을 잘 렌더링하는지 테스트', (
    WidgetTester tester,
  ) async {
    // 1. 가짜 화면(앱)에 우리가 만든 부품을 띄워봅니다.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EmptyStateView(message: "식단 기록이 없습니다.")),
      ),
    );

    // 2. 화면에 '식단 기록이 없습니다.'라는 글자가 1개 있는지 찾아봅니다.
    expect(find.text("식단 기록이 없습니다."), findsOneWidget);

    // 3. 화면에 박스(inbox) 아이콘이 잘 그려졌는지 찾아봅니다.
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  // 테스트 2: 에러 화면(ErrorMessageView) 렌더링 및 버튼 클릭 테스트
  testWidgets('ErrorMessageView 에러 문구 렌더링 및 다시 시도 버튼 클릭 테스트', (
    WidgetTester tester,
  ) async {
    bool isButtonClicked = false; // 버튼이 눌렸는지 확인하기 위한 변수

    // 1. 가짜 화면에 에러 부품을 띄웁니다.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorMessageView(
            errorMessage: "서버 연결 실패",
            onRetry: () {
              // 버튼이 눌리면 이 변수가 true로 바뀝니다!
              isButtonClicked = true;
            },
          ),
        ),
      ),
    );

    // 2. 에러 메시지("서버 연결 실패")가 화면에 잘 뜨는지 확인
    expect(find.text("서버 연결 실패"), findsOneWidget);

    // 3. '다시 시도' 버튼을 찾아서 가짜로 터치(클릭) 해봅니다.
    await tester.tap(find.text("다시 시도"));
    await tester.pump(); // 화면 업데이트

    // 4. 버튼이 정상적으로 눌려서 변수 값이 true로 바뀌었는지 최종 확인!
    expect(isButtonClicked, true);
  });
}
