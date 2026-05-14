import 'package:dangdang/app/navigation/main_shell.dart';
import 'package:flutter/material.dart';
// import '../features/auth/presentation/pages/login_page.dart';

class DangDangApp extends StatelessWidget {
  const DangDangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '당당하게',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MainShell(), // 로그인 화면 나중에 여기다가 하면 됨
    );
  }
}
