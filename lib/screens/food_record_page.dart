import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class FoodRecordPage extends StatelessWidget {
  const FoodRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
      // 우측 하단 카메라 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green,
        shape: const CircleBorder(),
        elevation: 6,
        child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              toolbarHeight: 70,
              title: const Text(
                '식단 기록',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
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
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(
                          '2026.03.26',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 컨테이너(카드) 영역
                    const _FoodRecordCard(
                      mealType: '점심',
                      time: '12:30',
                      calories: 605,
                      foodName: '비빔밥, 된장국',
                      itemCont: 2,
                    ),
                    const SizedBox(height: 25),

                    const _FoodRecordCard(
                      mealType: '저녁',
                      time: '18:30',
                      calories: 532,
                      foodName: '아보카도 비빔밥, 오이무침, 김자반',
                      itemCont: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
    return Container(
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
            borderRadius: BorderRadiusGeometry.circular(16),
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
                        style: TextStyle(
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
                      style: TextStyle(
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
              Icon(Icons.edit_outlined, color: Colors.grey.shade400, size: 24),
              const SizedBox(width: 10),
              Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}
