import 'package:dangdang/core/presentation/widgets/common/custom_bottom_navigation_bar.dart';
import 'package:dangdang/app/presentation/viewmodels/main_shell_view_model.dart';
import 'package:dangdang/features/ai_chat/presentation/views/ai_chat_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/views/blood_glucose_record_page.dart';
import 'package:dangdang/features/home/presentation/views/home_dashboard_page.dart';
import 'package:dangdang/features/meal/presentation/views/meal_record_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainShell extends ConsumerWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(mainShellViewModelProvider(initialIndex));
    final screens = const [
      HomeDashboardPage(),
      BloodSugarRecordPage(),
      MealRecordPage(),
      AiChatPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: viewModel.selectedIndex, children: screens),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: viewModel.selectedIndex,
        onTap: viewModel.selectIndex,
      ),
    );
  }
}
