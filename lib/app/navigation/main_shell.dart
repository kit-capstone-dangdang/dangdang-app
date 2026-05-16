import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_record_page.dart';
import 'package:flutter/material.dart';
import 'package:dangdang/core/widgets/common/custom_bottom_navigation_bar.dart';
import 'package:dangdang/features/home/presentation/pages/home_dashboard_page.dart';
import 'package:dangdang/features/meal/presentation/pages/meal_record_page.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const HomeDashboardPage(),
    const BloodSugarRecordPage(),
    const MealRecordPage(),
    const Center(child: Text('AI 챗 화면')),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

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
