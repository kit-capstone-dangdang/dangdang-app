import '../widgets/common/custom_icon.dart';
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

class _FoodRecordCard extends StatelessWidget {
  final String mealType;
  final String time;
  final int calories;
  final String foodName;
  final int itemCont;

  const _FoodRecordCard({
    required this.mealType,
    required this.time,
    required this.calories,
    required this.foodName,
    required this.itemCont,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 GestureDetector를 추가해서 카드 전체를 클릭 가능하게 만들었습니다.
    return GestureDetector(
      onTap: () {
        // 클릭 시 FoodAnalysisResultPage로 이동!
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MealAnalysisResultPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 왼쪽 음식 사진 영역
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 75,
                height: 75,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(width: 15),

            // 가운데 텍스트 및 정보 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mealType,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '$calories kcal',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // 두 번째 줄: 음식 이름
                  Text(
                    foodName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // 세 번째 줄: 품목 개수
                  Text(
                    '$itemCont개 품목',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // 수정/삭제 아이콘 영역
            Row(
              children: [
                CustomIcon(
                  icon: Icons.edit_outlined,
                  size: 24,
                  iconColor: Colors.grey.shade400,
                  onPressed: () {},
                ),
                const SizedBox(width: 10),
                CustomIcon(
                  icon: Icons.delete_outlined,
                  size: 24,
                  iconColor: Colors.grey.shade400,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
