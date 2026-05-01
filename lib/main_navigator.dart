import 'package:flutter/material.dart';
import './screens/home_dashboard_page.dart';
import 'screens/meal_record_page.dart';
import 'widgets/common/custom_bottom_navigation_bar.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboardPage(),
    const Center(child: Text('혈당 기록 화면')),
    const MealRecordPage(),
    const Center(child: Text('AI 챗 화면')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
