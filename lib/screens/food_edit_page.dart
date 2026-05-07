import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/food_item.dart';
import '../model/meal_record.dart';
import '../repositories/firebase_meal_repository.dart';

class FoodEditPage extends StatefulWidget {
  final XFile? image;
  final Map<String, dynamic> result;

  const FoodEditPage({super.key, required this.image, required this.result});

  @override
  State<FoodEditPage> createState() => _FoodEditPageState();
}

class _FoodEditPageState extends State<FoodEditPage> {
  final FirebaseMealRepository _mealRepository = FirebaseMealRepository();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedMeal = '점심';
  List<double> quantities = [];
  bool _isSaving = false;

  List<dynamic> get foods => widget.result['foods'] as List<dynamic>? ?? [];

  double _toDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  String _amountLabelFromItem(Map<String, dynamic> item) {
    final amountLabel = item['amountLabel']?.toString();
    if (amountLabel != null && amountLabel.isNotEmpty) {
      return amountLabel;
    }

    final amount = item['amount']?.toString();
    if (amount != null && amount.isNotEmpty) {
      return amount;
    }

    return '1인분';
  }

  double _calculateCalories({
    required double carbohydrate,
    required double protein,
    required double fat,
  }) {
    return (carbohydrate * 4) + (protein * 4) + (fat * 9);
  }

  List<FoodItem> _buildFoodItems() {
    return List.generate(foods.length, (index) {
      final item = foods[index] as Map<String, dynamic>;
      final quantity = quantities[index];

      final baseCarbohydrate = _toDouble(item['carbohydrate']);
      final baseProtein = _toDouble(item['protein']);
      final baseFat = _toDouble(item['fat']);
      final baseSugar = _toDouble(item['sugar']);

      final carbohydrate = baseCarbohydrate * quantity;
      final protein = baseProtein * quantity;
      final fat = baseFat * quantity;
      final sugar = baseSugar * quantity;
      final calories = _calculateCalories(
        carbohydrate: carbohydrate,
        protein: protein,
        fat: fat,
      );

      return FoodItem(
        name: item['name']?.toString() ?? '',
        amountLabel: _amountLabelFromItem(item),
        servingCount: quantity,
        calories: calories,
        carbohydrate: carbohydrate,
        protein: protein,
        fat: fat,
        sugar: sugar,
      );
    });
  }

  Map<String, double> _buildTotalNutrition(List<FoodItem> foodItems) {
    double calories = 0;
    double carbohydrate = 0;
    double protein = 0;
    double fat = 0;
    double sugar = 0;

    for (final food in foodItems) {
      calories += food.calories;
      carbohydrate += food.carbohydrate;
      protein += food.protein;
      fat += food.fat;
      sugar += food.sugar;
    }

    return {
      'calories': calories,
      'carbohydrate': carbohydrate,
      'protein': protein,
      'fat': fat,
      'sugar': sugar,
    };
  }

  DateTime _buildSelectedDateTime() {
    final now = DateTime.now();
    final date = selectedDate ?? now;
    final time = selectedTime ?? TimeOfDay.now();

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  MealRecord _buildMealRecord() {
    final foodItems = _buildFoodItems();

    return MealRecord(
      id: '',
      dateTime: _buildSelectedDateTime(),
      mealType: selectedMeal,
      foods: foodItems,
      aiComment: widget.result['aiComment']?.toString() ?? '',
      totalNutrition: _buildTotalNutrition(foodItems),
    );
  }

  Future<void> _saveMealRecord() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final mealRecord = _buildMealRecord();
      await _mealRepository.createMeal(mealRecord);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('식단 기록이 저장되었습니다.')));

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    }
  }

  double get totalCalories {
    final totalNutrition = _buildTotalNutrition(_buildFoodItems());
    return totalNutrition['calories'] ?? 0;
  }

  int get totalCarbohydrate {
    final totalNutrition = _buildTotalNutrition(_buildFoodItems());
    return (totalNutrition['carbohydrate'] ?? 0).round();
  }

  int get totalProtein {
    final totalNutrition = _buildTotalNutrition(_buildFoodItems());
    return (totalNutrition['protein'] ?? 0).round();
  }

  int get totalFat {
    final totalNutrition = _buildTotalNutrition(_buildFoodItems());
    return (totalNutrition['fat'] ?? 0).round();
  }

  int get totalSugar {
    final totalNutrition = _buildTotalNutrition(_buildFoodItems());
    return (totalNutrition['sugar'] ?? 0).round();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Widget _nutrientItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    quantities = List.generate(foods.length, (index) {
      final item = foods[index] as Map<String, dynamic>;
      return _toDouble(item['servingCount'], defaultValue: 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              toolbarHeight: 70,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              title: const Text(
                '식단 정보 확인',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: widget.image == null
                          ? const Center(
                              child: Icon(
                                Icons.fastfood,
                                size: 64,
                                color: Colors.orange,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.file(
                                File(widget.image!.path),
                                width: double.infinity,
                                height: 280,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
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
                              const Text('식사 구분'),
                              DropdownButton<String>(
                                value: selectedMeal,
                                isDense: true,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: ['아침', '점심', '저녁', '야식']
                                    .map(
                                      (meal) => DropdownMenuItem(
                                        value: meal,
                                        child: Text(meal),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedMeal = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('기록시간'),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _pickDate,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            selectedDate == null
                                                ? '${DateTime.now()}'.split(
                                                    ' ',
                                                  )[0]
                                                : '${selectedDate!}'.split(
                                                    ' ',
                                                  )[0],
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: _pickTime,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            selectedTime == null
                                                ? TimeOfDay.now().format(
                                                    context,
                                                  )
                                                : selectedTime!.format(context),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '식단 구성 (${foods.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: List.generate(foods.length, (index) {
                        final item = foods[index] as Map<String, dynamic>;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name']?.toString() ?? '음식명 없음',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _amountLabelFromItem(item),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: quantities[index] > 0.1
                                        ? () {
                                            setState(() {
                                              quantities[index] = double.parse(
                                                (quantities[index] - 0.1)
                                                    .toStringAsFixed(1),
                                              );
                                            });
                                          }
                                        : null,
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text(
                                    '${quantities[index].toStringAsFixed(1)}인분',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        quantities[index] = double.parse(
                                          (quantities[index] + 0.1)
                                              .toStringAsFixed(1),
                                        );
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '총 영양 정보 합계',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    totalCalories.toStringAsFixed(0),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'kcal',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _nutrientItem('탄수', '${totalCarbohydrate}g'),
                              _nutrientItem('단백', '${totalProtein}g'),
                              _nutrientItem('지방', '${totalFat}g'),
                              _nutrientItem('당류', '${totalSugar}g'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMealRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                '저장하기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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
