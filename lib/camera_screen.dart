import 'package:flutter/material.dart';
import '../widgets/common/state_views.dart';

// 1. 로딩 상태를 기억하기 위해 StatefulWidget으로 변경!
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // 💡 로딩 상태를 관리할 변수
  bool _isLoading = false;

  // 💡 사진을 찍고 AI가 분석하는 척하는 가짜 함수
  void _takePictureAndAnalyze() async {
    setState(() {
      _isLoading = true; //로딩 창 띄우기
    });

    // 진짜 서버로 사진 보내서 분석하는 시간 (2초 대기)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false; // 분석 끝! 로딩 창 숨기기
    });

    // 분석이 끝나면 다음 화면(예: 방금 만든 식단 수정 화면)으로 넘어가야 합니다!
    // 지금은 테스트용으로 이전 화면으로 돌아가게 해둘게요.
    if (mounted) {
      Navigator.pop(context);
      // 나중에 실제 연결할 때는 아래처럼 Navigator.push 로 바꾸시면 됩니다!
      // Navigator.push(context, MaterialPageRoute(builder: (context) => const MealEditPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음식 촬영'),
        backgroundColor: Colors.grey[200],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Stack(
          children: [
            // 진짜 카메라 화면 대신 회색 배경으로 표시
            Container(color: Colors.black.withOpacity(0.8)),
            const Center(
              child: Text(
                '카메라 화면이 나타납니다.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            // 3. 하단 촬영 버튼 바
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(30),
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _takePictureAndAnalyze,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
