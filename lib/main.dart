import 'package:dangdang/screens/food_analysis_result_page.dart';
import 'package:flutter/material.dart';
import 'main_navigator.dart';

void main() {
  runApp(const DangDangApp());
}

class DangDangApp extends StatelessWidget {
  const DangDangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '당당하게',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F69FE)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainNavigator(),
    );
  }
}
