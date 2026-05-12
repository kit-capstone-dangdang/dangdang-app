import 'package:dangdang/app/navigation/main_shell.dart';
import 'package:flutter/material.dart';

class DangDangApp extends StatelessWidget {
  const DangDangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '당당하게',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}
