import 'package:flutter/material.dart';
import 'meal_analysis_result_page.dart';
import '../widgets/meal_record/meal_record_card.dart';
import '../widgets/date/date_header.dart';

class MealRecordPage extends StatelessWidget {
  const MealRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: false,
                snap: true,
                backgroundColor: colorScheme.surface,
                surfaceTintColor: colorScheme.surface,
                toolbarHeight: 70,
                automaticallyImplyLeading: false,
                title: Text(
                  '식단 기록',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜 영역
                      const DateHeader(date: '2026.03.26'),
                      const SizedBox(height: 16),

                      // 식단 기록 컨테이너(카드) 영역
                      MealRecordCard(
                        mealType: '점심',
                        time: '12:30',
                        calories: 605,
                        foodName: '비빔밥, 된장국',
                        itemCount: 2,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MealAnalysisResultPage(),
                            ),
                          );
                        },
                        onEdit: () {},
                        onDelete: () {},
                      ),
                      const SizedBox(height: 25),

                      MealRecordCard(
                        mealType: '저녁',
                        time: '18:30',
                        calories: 532,
                        foodName: '아보카도 비빔밥, 오이무침, 김자반',
                        itemCount: 3,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MealAnalysisResultPage(),
                            ),
                          );
                        },
                        onEdit: () {},
                        onDelete: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 우측 하단 카메라 버튼
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.green,
              shape: const CircleBorder(),
              elevation: 6,
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
