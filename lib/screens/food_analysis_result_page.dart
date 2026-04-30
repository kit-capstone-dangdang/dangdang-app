import 'package:dangdang/data/food_analysis_result_dummy_data.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class FoodAnalysisResultPage extends StatelessWidget {
  const FoodAnalysisResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    const result = dummyFoodAnalysisResult;

    return Scaffold(
      backgroundColor: Colors.white,
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
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                ),
              ),
              title: const Text(
                '식단 상세',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              centerTitle: false,
              actions: [
                _buildIconButton(
                  Icons.edit_outlined,
                  const Color(0xFFF2F4FB),
                  Colors.black,
                ),
                const SizedBox(width: 10),
                _buildIconButton(
                  Icons.delete_outline_outlined,
                  const Color(0xFFF2F4FB),
                  Colors.red,
                ),
                const SizedBox(width: 12),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 음식 사진 영역
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 64,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 영양 요약 카드
                    Container(
                      padding: const EdgeInsets.all(22),
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '총 영양 정보 합계',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${result.totalCalories} kcal',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildNutrient(
                                '탄수',
                                '${result.carbohydrates}g',
                                false,
                              ),
                              _buildNutrient('단백', '${result.protein}g', false),
                              _buildNutrient('지방', '${result.fat}g', false),
                              _buildNutrient('당류', '${result.sugar}g', true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 상세 품목 타이틀
                    Text(
                      '상세 품목 (${result.items.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 음식 아이템 리스트
                    ...result.items.map(
                      (item) => Container(
                        padding: const EdgeInsets.all(22),
                        margin: const EdgeInsets.only(bottom: 14),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  item.servingText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${item.calories} kcal',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // AI 분석 카드
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 240, 253, 226),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI 식단 분석',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 38, 103, 40),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            result.aiComment,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w200,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 목록으로 돌아가기 버튼
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 6, 77, 134),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          '목록으로 돌아가기',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}

Widget _buildIconButton(IconData icon, Color bgColor, Color iconColor) {
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: IconButton(
      onPressed: () {},
      icon: Icon(icon, color: iconColor),
    ),
  );
}

Widget _buildNutrient(String label, String value, bool isHighlight) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: isHighlight
          ? const Color.fromARGB(255, 253, 232, 232)
          : Colors.grey[100],
      borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isHighlight ? Colors.red : Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            color: isHighlight ? Colors.red : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
