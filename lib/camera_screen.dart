import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. 뒤로가기 버튼이 있는 앱바
      appBar: AppBar(
        title: const Text('음식 촬영'),
        backgroundColor: Colors.grey[200],
      ),
      // 2. 카메라 화면을 시뮬레이션하는 영역
      body: Stack(
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
                  // 가짜 촬영 버튼 (동그라미)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}