import 'package:dangdang/core/widgets/common/custom_card.dart';
import 'package:dangdang/core/widgets/common/custom_icon.dart';
import 'package:dangdang/features/meal/data/repositories/firebase_meal_repository.dart';
import 'package:dangdang/features/meal/domain/entities/meal_record.dart';
import 'package:dangdang/features/meal/presentation/pages/food_edit_page.dart';
import 'package:dangdang/features/meal/presentation/widgets/food_detail_item_card.dart';
import 'package:dangdang/features/meal/presentation/widgets/nutrition_summary_box.dart';
import 'package:flutter/material.dart';

class MealAnalysisResultPage extends StatelessWidget {
  final MealRecord record;

  const MealAnalysisResultPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final repository = FirebaseMealRepository();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: StreamBuilder<MealRecord?>(
          stream: repository.watchMeal(record.id),
          initialData: record,
          builder: (context, snapshot) {
            final currentRecord = snapshot.data;

            if (snapshot.connectionState == ConnectionState.waiting &&
                currentRecord == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (currentRecord == null) {
              return Center(
                child: Text(
                  '식단 기록을 찾을 수 없습니다.',
                  style: textTheme.bodyLarge,
                ),
              );
            }

            final totalNutrition = currentRecord.totalNutrition;
            final foods = currentRecord.foods;
            final aiComment = currentRecord.aiComment;

            return CustomScrollView(
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FoodEditPage(originalRecord: currentRecord),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomIcon(
                      icon: Icons.delete_outlined,
                      backgroundColor: Colors.grey.shade100,
                      iconColor: colorScheme.error,
                      onPressed: () async {
                        final bool? confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: colorScheme.surface,
                              title: Text(
                                '식단 삭제',
                                style: textTheme.titleLarge,
                              ),
                              content: const Text(
                                '이 식단 기록을 정말 삭제하시겠습니까?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    '취소',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text(
                                    '삭제',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true && context.mounted) {
                          try {
                            await repository.deleteMeal(
                              currentRecord.id,
                              imageUrl: currentRecord.imageUrl,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('성공적으로 삭제했습니다.'),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('삭제 중 오류가 발생했습니다.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
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
                        CustomCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 38,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(38),
                            child: currentRecord.imageUrl.isEmpty
                                ? SizedBox(
                                    height: 300,
                                    width: double.infinity,
                                    child: Center(
                                      child: Icon(
                                        Icons.fastfood,
                                        size: 64,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    currentRecord.imageUrl,
                                    height: 300,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        NutritionSummaryBox(
                          calories: (totalNutrition['calories'] ?? 0).round(),
                          carbohydrate: (totalNutrition['carbohydrate'] ?? 0)
                              .round(),
                          protein: (totalNutrition['protein'] ?? 0).round(),
                          fat: (totalNutrition['fat'] ?? 0).round(),
                          sugar: (totalNutrition['sugar'] ?? 0).round(),
                        ),
                        const SizedBox(height: 22),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            '식단 상세 구성 (${foods.length})',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...foods.map((food) => FoodDetailItemCard(item: food)),
                        const SizedBox(height: 10),
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
                        CustomCard(
                          onTap: () => Navigator.pop(context),
                          backgroundColor: colorScheme.primary,
                          showShadow: false,
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
            );
          },
        ),
      ),
    );
  }
}
