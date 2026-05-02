import 'package:dangdang/data/food_analysis_result_dummy_data.dart';
import 'package:flutter/material.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/common/custom_icon.dart';
import 'meal_edit_page.dart';

class MealAnalysisResultPage extends StatefulWidget {
  const MealAnalysisResultPage({super.key});

  @override
  State<MealAnalysisResultPage> createState() => _MealAnalysisResultPageState();
}

class _MealAnalysisResultPageState extends State<MealAnalysisResultPage> {
  // 화면에 보여줄 총 칼로리를 상태(State) 변수로 만듭니다.
  late int _currentTotalCalories;
  final result = dummyFoodAnalysisResult;

  @override
  void initState() {
    super.initState();
    // 처음 화면이 켜질 때는 더미 데이터의 칼로리를 쏙 가져옵니다.
    _currentTotalCalories = result.totalCalories;
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => Navigator.pop(context),
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
                CustomIcon(
                  icon: Icons.edit_outlined,
                  backgroundColor: Colors.grey.shade100,
                  iconColor: Colors.black,
                  onPressed: () {
                    // 💡 연필 아이콘을 누르면 0.1인분 조절 화면으로 이동!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MealEditPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                CustomIcon(
                  icon: Icons.delete_outlined,
                  backgroundColor: Colors.grey.shade100,
                  iconColor: Colors.red,
                  onPressed: () {
                    // 삭제 기능은 나중에!
                  },
                ),
                const SizedBox(width: 24),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 음식 사진 영역 (사진은 곡률이 달라 CustomCard 대신 유지하거나 매개변수 조절)
                    CustomCard(
                      padding: EdgeInsets.zero, // 사진 꽉 차게
                      borderRadius: 38,
                      backgroundColor: Colors.grey[300]!,
                      child: const SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 64,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 2. 영양 요약 카드
                    CustomCard(
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
                                  color: Color.fromARGB(255, 17, 48, 189),
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
                    const Text(
                      '상세 품목',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. 음식 아이템 리스트 (CustomCard 적용)
                    ...result.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: CustomCard(
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
                                  color: Color.fromARGB(255, 17, 48, 189),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 4. AI 분석 카드 (CustomCard 배경색 변경 적용)
                    CustomCard(
                      backgroundColor: const Color.fromARGB(255, 240, 253, 226),
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

                    // 5. 목록으로 돌아가기 버튼 (CustomCard를 버튼처럼 사용)
                    CustomCard(
                      onTap: () => Navigator.pop(context),
                      backgroundColor: const Color.fromARGB(255, 6, 77, 134),
                      showShadow: false, // 버튼은 그림자 제외 (선택사항)
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
    );
  }
}

// 영양소 위젯 (이것도 필요하면 별도 파일로 분리 가능)
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
