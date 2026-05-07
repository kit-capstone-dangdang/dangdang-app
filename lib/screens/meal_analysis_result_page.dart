import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/common/custom_icon.dart';
import '../widgets/meal_analysis_result/nutrition_summary_card.dart';
import '../widgets/meal_analysis_result/food_detail_item_card.dart';
import 'dart:io';

class MealAnalysisResultPage extends StatelessWidget {
  final XFile image;
  final Map<String, dynamic> analysisResult;

  const MealAnalysisResultPage({
    super.key,
    required this.image,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final totalNutrition =
        analysisResult['totalNutrition'] as Map<String, dynamic>;
    final foods = analysisResult['foods'] as List<dynamic>;
    final aiComment = analysisResult['aiComment'] ?? '';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              backgroundColor: colorScheme.surface,
              surfaceTintColor: colorScheme.surface,
              toolbarHeight: 70,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colorScheme.onSurface,
                ),
              ),
              title: Text(
                '식단 상세',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              centerTitle: false,
              actions: [
                CustomIcon(
                  icon: Icons.edit_outlined,
                  backgroundColor: Colors.grey.shade100,
                  iconColor: colorScheme.onSurface,
                  onPressed: () {},
                ),
                const SizedBox(width: 10),
                CustomIcon(
                  icon: Icons.delete_outlined,
                  backgroundColor: Colors.grey.shade100,
                  iconColor: colorScheme.error,
                  onPressed: () {},
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
                    // 1. 음식 사진 영역
                    CustomCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 38,
                      backgroundColor: Colors.grey.shade200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(38),
                        child: Image.file(
                          File(image.path),
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
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
                              Text(
                                '총 영양 정보 합계',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${totalNutrition['calories']} kcal',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              NutritionSummaryCard(
                                label: '탄수',
                                value: '${totalNutrition['carbohydrate']}g',
                              ),
                              NutritionSummaryCard(
                                label: '단백',
                                value: '${totalNutrition['protein']}g',
                              ),
                              NutritionSummaryCard(
                                label: '지방',
                                value: '${totalNutrition['fat']}g',
                              ),
                              NutritionSummaryCard(
                                label: '당류',
                                value: '${totalNutrition['sugar']}g',
                                isHighlight: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 상세 품목 타이틀
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        '상세 품목 (${foods.length})',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. 음식 아이템 리스트 (CustomCard 적용)
                    ...foods.map((food) {
                      return FoodDetailItemCard(
                        item: food as Map<String, dynamic>,
                      );
                    }),
                    const SizedBox(height: 10),

                    // 4. AI 분석 카드 (CustomCard 배경색 변경 적용)
                    CustomCard(
                      backgroundColor: Colors.green.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI 식단 분석',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            aiComment,
                            style: textTheme.bodyMedium?.copyWith(
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
                      backgroundColor: colorScheme.primary,
                      showShadow: false, // 버튼은 그림자 제외 (선택사항)
                      child: Center(
                        child: Text(
                          '목록으로 돌아가기',
                          style: textTheme.headlineSmall?.copyWith(
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
