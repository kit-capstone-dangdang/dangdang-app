import 'package:flutter/material.dart';
import 'home_dashboard.dart'; // 우리가 만든 홈 화면 불러오기

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  // 현재 선택된 탭의 인덱스 (0: 홈, 1: 혈당, 2: 식단, 3: AI챗)
  int _selectedIndex = 0;

  // 탭을 눌렀을 때 보여줄 화면들 리스트
  final List<Widget> _screens = [
    const HomeDashboard(), // 1. 우리가 만든 메인 홈 화면!
    const Center(child: Text('혈당 기록 화면이 들어올 자리입니다.', style: TextStyle(fontSize: 18))), // 2. 혈당
    const Center(child: Text('식단 기록 화면이 들어올 자리입니다.', style: TextStyle(fontSize: 18))), // 3. 식단
    const Center(child: Text('GlucoCare AI 챗 화면이 들어올 자리입니다.', style: TextStyle(fontSize: 18))), // 4. AI 챗
  ];

  // 하단 바의 아이콘을 눌렀을 때 실행되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 누른 인덱스로 상태 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 인덱스에 맞는 화면을 body에 뿌려줍니다.
      body: _screens[_selectedIndex],

      // 여기가 바로 사진에서 보여주신 하단 위젯바 부분입니다!
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 탭이 4개 이상일 때 움직이지 않도록 고정
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex, // 현재 활성화된 탭
        onTap: _onItemTapped,         // 눌렀을 때 작동할 함수
        selectedItemColor: const Color(0xFF2F69FE), // 선택됐을 때 색상 (파란색)
        unselectedItemColor: const Color(0xFFB0B0B0), // 선택 안 됐을 때 색상 (회색)
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),

        // 하단 바에 들어갈 아이템 4개 정의
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart), // 혈당 느낌의 차트 아이콘
            label: '혈당',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu), // 식단 느낌의 포크/나이프 아이콘
            label: '식단',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), // AI챗 느낌의 말풍선 아이콘
            label: 'AI 챗',
          ),
        ],
      ),
    );
  }
}