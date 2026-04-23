import 'package:flutter/material.dart';
import 'camera_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  // '식단 촬영' 버튼을 눌렀을 때 하단 바텀 시트를 띄우는 함수
  void _showDietCaptureBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 바텀 시트 높이 조절 가능하게
      backgroundColor: Colors.transparent, // 배경을 투명하게 해서 둥근 모서리 표현
      builder: (BuildContext context) {
        return Container(
          // 둥근 모서리 디자인
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞춤
            children: [
              // 1. 하단 시트 손잡이 (작은 회색 바)
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 30),

              // 2. 카메라로 촬영하기 버튼 (핵심 디자인 - image_6.png 파란색 버튼)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraScreen()),
                  );
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                label: const Text('카메라로 촬영하기', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F69FE), // 파란색
                  minimumSize: const Size(double.infinity, 60), // 가로 가득, 세로 60
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5, // 그림자
                ),
              ),
              const SizedBox(height: 15),

              // 3. 갤러리에서 선택하기 버튼 (image_6.png 연한색 버튼)
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: 갤러리 열기 기능 구현 예정
                  Navigator.pop(context); // 시트 닫기
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('갤러리를 엽니다.')));
                },
                icon: const Icon(Icons.add, color: Color(0xFF555555), size: 24),
                label: const Text('갤러리에서 선택하기', style: TextStyle(color: Color(0xFF555555), fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F4F7), // 연한 회색
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0, // AppBar 영역을 없애고 body에 직접 구현
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더 영역 (안녕하세요...)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕하세요, 김당뇨님!',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '오늘도 건강한 하루 되세요.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                // 프로필 아이콘 (김)
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFE8F0FE),
                  child: const Text('김', style: TextStyle(color: Color(0xFF2F69FE), fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 2. 혈당 카드
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF2F69FE), // 파란색 배경
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B8EFF), // 좀 더 연한 파란색
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('최근 혈당', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const Icon(Icons.trending_up, color: Colors.white, size: 20),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '105',
                        style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'mg/dL',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '✓ 정상 범위 내에 있습니다 (공복)',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 3. 기록 및 촬영 버튼 영역
            Row(
              children: [
                // 혈당 기록 버튼 (plus icon)
                _buildActionButton(Icons.add_circle_outline, '혈당 기록', const Color(0xFFE8F0FE), const Color(0xFF2F69FE), () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('혈당 기록 화면으로 이동합니다.')));
                }),
                const SizedBox(width: 20),
                // 식단 촬영 버튼 (camera icon) - 핵심 기능
                _buildActionButton(Icons.camera_alt_outlined, '식단 촬영', const Color(0xFFE8FAF1), const Color(0xFF12B76A), () {
                  // 버튼을 눌렀을 때 하단 시트를 띄움
                  _showDietCaptureBottomSheet(context);
                }),
              ],
            ),
            const SizedBox(height: 35),

            // 4. 혈당 리포트 섹션
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('혈당 리포트', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: const Text('자세히 보기', style: TextStyle(color: Color(0xFF2F69FE)))),
                  ],
                ),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  // 임시 그래프 이미지 플레이스홀더
                  child: const Center(child: Text('그래프 영역 (그래프 패키지 필요)', style: TextStyle(color: Colors.grey))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 개별 버튼 생성기 위젯
  Widget _buildActionButton(IconData icon, String label, Color bgColor, Color iconColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(height: 15),
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}