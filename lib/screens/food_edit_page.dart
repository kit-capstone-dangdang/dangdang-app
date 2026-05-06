import 'package:flutter/material.dart';
import '../data/food_analysis_result_dummy_data.dart';
import '../widgets/food_item_card.dart';

class FoodEditPage extends StatefulWidget {
  const FoodEditPage({super.key});

  @override
  State<FoodEditPage> createState() => _FoodEditPageState();
}

class _FoodEditPageState extends State<FoodEditPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedMeal = '점심';
  List<double> quantities = [];

  // 날짜 선택
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // 시간 선택
  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
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
void _selectMeal() {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final meals = ['아침', '점심', '저녁', '야식'];

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: meals.map((meal) {
            return ListTile(
              title: Text(meal),
              trailing: selectedMeal == meal
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() {
                  selectedMeal = meal;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      );
    },
  );
}

@override
void initState() {
  super.initState();
  final result = dummyFoodAnalysisResult;

  quantities = List.generate(result.items.length, (index) => 1.0);
}
  @override
  Widget build(BuildContext context) {
    final result = dummyFoodAnalysisResult;
    double totalCalories = 0;

    for (int i = 0; i < result.items.length; i++) {
      totalCalories += result.items[i].calories * quantities[i];
    }

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
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              title: const Text(
                '식단 정보 확인',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 음식 이미지
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 64,
                          color: Colors.orange,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 식사 정보 카드
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
                          // 식사 구분
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('식사 구분'),

                              DropdownButton<String>(
                                value: selectedMeal,
                                isDense: true,
                                underline: const SizedBox(), // 밑줄 제거
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: ['아침', '점심', '저녁', '야식']
                                    .map((meal) => DropdownMenuItem(
                                          value: meal,
                                          child: Text(meal),
                                        ))
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

                          // 기록 시간
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('기록시간'),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _pickDate,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F5), // ⭐ 옅은 회색
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            selectedDate == null
                                                ? '${DateTime.now()}'.split(' ')[0]
                                                : '${selectedDate!}'.split(' ')[0],
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.calendar_today, size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: _pickTime,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            selectedTime == null
                                                ? TimeOfDay.now().format(context)
                                                : selectedTime!.format(context),
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.access_time, size: 16),
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
                      '식단 구성 (${result.items.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Column(
                      children: List.generate(result.items.length, (index) {
                        final item = result.items[index];
                        return FoodItemCard(
                          item: item,
                          quantity: quantities[index],
                          onChanged: (value) {
                            setState(() {
                              quantities[index] = value;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF2563EB),
                          ],
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
                              _nutrientItem('탄수', '${result.carbohydrates}g'),
                              _nutrientItem('단백', '${result.protein}g'),
                              _nutrientItem('지방', '${result.fat}g'),
                              _nutrientItem('당류', '${result.sugar}g'),
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
                        onPressed: () {
                          print(selectedMeal);
                          print(selectedDate);
                          print(selectedTime);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
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