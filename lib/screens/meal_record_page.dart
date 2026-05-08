import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/meal_record.dart';
import '../widgets/meal_record/meal_record_card.dart';
import '../widgets/date/date_header.dart';
import '../repositories/firebase_meal_repository.dart';
import 'package:dangdang/features/image_input/image_picker_service.dart';
import '../widgets/common/state_views.dart';
import '../services/gemini_service.dart';
import '../screens/analysis_result.dart';
import 'meal_analysis_result_page.dart';
import '../screens/food_edit_page.dart';

class MealRecordPage extends StatefulWidget {
  const MealRecordPage({super.key});

  @override
  State<MealRecordPage> createState() => _MealRecordPageState();
}

class _MealRecordPageState extends State<MealRecordPage> {
  bool _isLoading = false;

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _foodNames(List<MealRecord> records, int index) {
    return records[index].foods.map((food) => food.name).join(', ');
  }

  int _totalCalories(MealRecord record) {
    return (record.totalNutrition['calories'] ?? 0).round();
  }

  Future<void> _pickImageAndAnalyze({
    required BuildContext context,
    required Future<XFile?> Function() pickImage,
    bool fromBottomSheet = true,
  }) async {
    if (fromBottomSheet) {
      Navigator.pop(context);
    }

    final XFile? image = await pickImage();

    if (image == null || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final geminiService = GeminiService();

      final mealRecord = await geminiService.analyzeFoodImage(
        image: image,
        mealType: '식사',
        dateTime: DateTime.now(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final action = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AnalysisResult(image: image, result: mealRecord.toJson()),
        ),
      );

      if (action == 'retake' && mounted) {
        Future.microtask(() {
          _pickImageAndAnalyze(
            context: context,
            pickImage: pickImage,
            fromBottomSheet: false,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('분석 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDietCaptureBottomSheet(BuildContext context) {
    final ImagePickerService imagePickerService = ImagePickerService();
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () async {
                  await _pickImageAndAnalyze(
                    context: parentContext,
                    pickImage: imagePickerService.pickFromCamera,
                  );
                },
                icon: Icon(
                  Icons.camera_alt,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
                label: Text(
                  '카메라로 촬영하기',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () async {
                  await _pickImageAndAnalyze(
                    context: parentContext,
                    pickImage: imagePickerService.pickFromGallery,
                  );
                },
                icon: Icon(
                  Icons.image_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                label: Text(
                  '갤러리에서 선택하기',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final repository = FirebaseMealRepository();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
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
                  StreamBuilder<List<MealRecord>>(
                    stream: repository.watchMeals(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return const SliverFillRemaining(
                          child: Center(child: Text('식단 기록을 불러오지 못했습니다.')),
                        );
                      }

                      final records = snapshot.data ?? [];

                      if (records.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: Text('저장된 식단 기록이 없습니다.')),
                        );
                      }

                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(records.length, (index) {
                              final record = records[index];
                              bool showDateHeader = false;

                              if (index == 0) {
                                showDateHeader = true;
                              } else {
                                final prevDate = _formatDate(
                                  records[index - 1].dateTime,
                                );
                                final currDate = _formatDate(record.dateTime);
                                if (prevDate != currDate) {
                                  showDateHeader = true;
                                }
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showDateHeader) ...[
                                    if (index > 0) const SizedBox(height: 32),
                                    DateHeader(
                                      date: _formatDate(record.dateTime),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 25),
                                    child: MealRecordCard(
                                      mealType: record.mealType,
                                      time: _formatTime(record.dateTime),
                                      calories: _totalCalories(record),
                                      foodName: _foodNames(records, index),
                                      itemCount: record.foods.length,
                                      imageUrl: record.imageUrl,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                MealAnalysisResultPage(
                                                  record: record,
                                                ),
                                          ),
                                        );
                                      },
                                      onEdit: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FoodEditPage(
                                              originalRecord: record,
                                            ),
                                          ),
                                        );
                                      },
                                      onDelete: () async {
                                        final bool? confirmDelete =
                                            await showDialog<bool>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      colorScheme.surface,
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
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: Text(
                                                        '취소',
                                                        style: TextStyle(
                                                          color: colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        '삭제',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                        if (confirmDelete == true &&
                                            context.mounted) {
                                          try {
                                            await repository.deleteMeal(
                                              record.id,
                                              imageUrl: record.imageUrl,
                                            );

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    '성공적으로 삭제되었습니다.',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    '삭제 중 오류가 발생했습니다.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    _showDietCaptureBottomSheet(context);
                  },
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
        ),
      ),
    );
  }
}
