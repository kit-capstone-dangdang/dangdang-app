import 'package:flutter/material.dart';

import 'screens/food_record_page.dart';

void main() {
  runApp(const DangDangApp());
}

class DangDangApp extends StatelessWidget {
  const DangDangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DangDang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4B5CF0)),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const FoodRecordPage(),
    );
  }
}
