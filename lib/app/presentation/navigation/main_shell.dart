import 'package:dangdang/core/presentation/widgets/common/custom_bottom_navigation_bar.dart';
import 'package:dangdang/app/presentation/models/main_shell_model.dart';
import 'package:dangdang/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_record_page.dart';
import 'package:dangdang/features/home/presentation/pages/home_dashboard_page.dart';
import 'package:dangdang/features/meal/presentation/pages/meal_record_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainShell extends ConsumerWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(mainShellProvider(initialIndex));
    final screens = const [
      HomeDashboardPage(),
      BloodSugarRecordPage(),
      MealRecordPage(),
      AiChatPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: model.selectedIndex, children: screens),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: model.selectedIndex,
        onTap: model.selectIndex,
      ),
    );
  }
}