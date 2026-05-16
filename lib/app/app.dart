import 'package:dangdang/app/navigation/main_shell.dart';
import 'package:dangdang/features/auth/presentation/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const MainShell();
          }

          return const LoginPage();
        },
      ),
    );
  }
}
