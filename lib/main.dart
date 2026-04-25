import 'package:dangdang/screens/food_analysis_result_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DangDangApp());
}

class DangDangApp extends StatelessWidget {
  const DangDangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DangDang',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F63F6)),
      ),
      home: const FoodAnalysisResultPage(),
    );
  }
}
