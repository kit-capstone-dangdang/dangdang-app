import 'package:dangdang/app/presentation/navigation/main_shell.dart';
import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/auth/presentation/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DangDangApp extends ConsumerWidget {
  const DangDangApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

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
      home: authState.when(
        loading: () => const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const LoginPage(),
        data: (user) => user != null ? const MainShell() : const LoginPage(),
      ),
    );
  }
}
