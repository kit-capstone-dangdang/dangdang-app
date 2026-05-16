import 'dart:typed_data';
import 'package:dangdang/app/navigation/main_shell.dart';
import 'package:dangdang/core/utils/parsers/value_parser.dart';
import 'package:dangdang/features/meal/data/repositories/firebase_meal_repository.dart';
import 'package:dangdang/features/meal/data/services/image_picker_service.dart';
import 'package:dangdang/features/meal/data/services/meal_image_storage_service.dart';
import 'package:dangdang/features/meal/data/services/meal_ai_service.dart';
import 'package:dangdang/features/meal/domain/entities/food_item.dart';
import 'package:dangdang/features/meal/domain/entities/meal_record.dart';
import 'package:dangdang/features/meal/domain/services/nutrition_aggregator.dart';
import 'package:dangdang/features/meal/presentation/widgets/food_item_card.dart';
import 'package:dangdang/features/meal/presentation/widgets/nutrition_summary_box.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodEditPage extends StatefulWidget {
  final XFile? image;
  final Map<String, dynamic>? result;
  final MealRecord? originalRecord;

  const FoodEditPage({super.key, this.image, this.result, this.originalRecord});

  @override
  State<FoodEditPage> createState() => _FoodEditPageState();
}

class _FoodEditPageState extends State<FoodEditPage> {
  final FirebaseMealRepository _mealRepository = FirebaseMealRepository();
  final MealImageStorageService _imageStorageService =
      MealImageStorageService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final MealAiService _mealAiService = MealAiService();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedMeal = '점심';
  List<double> quantities = [];
  bool _isSaving = false;

  List<FoodItem> _baseFoods = [];
  late List<String> _initialNames;
  String? _networkImageUrl;
  XFile? _newImage;

  @override
  void initState() {
    super.initState();

    if (widget.originalRecord != null) {
      selectedDate = widget.originalRecord!.dateTime;
      selectedTime = TimeOfDay.fromDateTime(widget.originalRecord!.dateTime);
      selectedMeal = widget.originalRecord!.mealType;
      _networkImageUrl = widget.originalRecord!.imageUrl;

      _baseFoods = widget.originalRecord!.foods.map((food) {
        return food.scaled(1 / food.servingCount);
      }).toList();

      quantities = widget.originalRecord!.foods
          .map((e) => e.servingCount)
          .toList();
    } else {
      final rawFoods = widget.result?['foods'] as List<dynamic>? ?? [];

      _baseFoods = rawFoods.map((item) {
        final mapItem = item as Map<String, dynamic>;

        double analyzeServingCount = parseDouble(
          mapItem['servingCount'],
          defaultValue: 1.0,
        );
        if (analyzeServingCount <= 0) analyzeServingCount = 1.0;

        final calories = parseDouble(mapItem['calories']) / analyzeServingCount;
        final carbohydrate =
            parseDouble(mapItem['carbohydrate']) / analyzeServingCount;
        final protein = parseDouble(mapItem['protein']) / analyzeServingCount;
        final fat = parseDouble(mapItem['fat']) / analyzeServingCount;
        final sugar = parseDouble(mapItem['sugar']) / analyzeServingCount;

        return FoodItem(
          name: mapItem['name']?.toString() ?? '',
          amountLabel: _amountLabelFromItem(mapItem),
          servingCount: 1.0,
          calories: calories,
          carbohydrate: carbohydrate,
          protein: protein,
          fat: fat,
          sugar: sugar,
        );
      }).toList();

      quantities = rawFoods
          .map((item) => parseDouble(item['servingCount'], defaultValue: 1.0))
          .toList();
    }

    _initialNames = _baseFoods.map((f) => f.name).toList();
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

  Widget _buildPickedImage(XFile image) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Image.memory(
          snapshot.data!,
          width: double.infinity,
          height: 280,
          fit: BoxFit.cover,
        );
      },
    );
  }

  List<FoodItem> _buildFoodItems() {
    return List.generate(_baseFoods.length, (index) {
      return _baseFoods[index].scaled(quantities[index]);
    });
  }

  Map<String, double> get _currentTotalNutrition {
    return aggregateNutritionTotals(_buildFoodItems());
  }

  DateTime _buildSelectedDateTime() {
    final now = DateTime.now();
    final date = selectedDate ?? now;
    final time = selectedTime ?? TimeOfDay.now();
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  MealRecord _buildMealRecord({required String imageUrl}) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final foodItems = _buildFoodItems();

    return MealRecord(
      id: widget.originalRecord?.id ?? '',
      uid: widget.originalRecord?.uid ?? uid,
      dateTime: _buildSelectedDateTime(),
      mealType: selectedMeal,
      foods: foodItems,
      imageUrl: imageUrl,
      aiComment:
          widget.originalRecord?.aiComment ??
          widget.result?['aiComment']?.toString() ??
          '',
      totalNutrition: MealRecord.totalNutritionFromFoods(foodItems),
    );
  }

  Future<void> _showImagePicker(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '사진 교체하기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () async {
                Navigator.pop(context);
                final img = await _imagePickerService.pickFromCamera();
                if (img != null) setState(() => _newImage = img);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('갤러리에서 선택'),
              onTap: () async {
                Navigator.pop(context);
                final img = await _imagePickerService.pickFromGallery();
                if (img != null) setState(() => _newImage = img);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMealRecord() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      List<int> changedIndices = [];
      List<String> changedNames = [];

      for (int i = 0; i < _baseFoods.length; i++) {
        if (_baseFoods[i].name != _initialNames[i]) {
          changedIndices.add(i);
          changedNames.add(_baseFoods[i].name);
        }
      }

      if (changedNames.isNotEmpty) {
        final updatedItems = await _mealAiService.refineMultipleFoodsInfo(
          changedNames,
        );
        for (int i = 0; i < changedIndices.length; i++) {
          _baseFoods[changedIndices[i]] = updatedItems[i];
        }
      }

      String imageUrl = _networkImageUrl ?? '';
      final imageToUpload = _newImage ?? widget.image;

      if (imageToUpload != null) {
        imageUrl = await _imageStorageService.uploadMealImage(imageToUpload);
      }

      final mealRecord = _buildMealRecord(imageUrl: imageUrl);

      if (widget.originalRecord != null) {
        await _mealRepository.updateMeal(
          mealRecord,
          oldImageUrl: widget.originalRecord!.imageUrl,
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('식단 기록이 수정되었습니다.')));
        }
      } else {
        await _mealRepository.createMeal(mealRecord);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('식단 기록이 저장되었습니다.')));
        }
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 2)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  double get totalCalories => _currentTotalNutrition['calories'] ?? 0;
  int get totalCarbohydrate =>
      (_currentTotalNutrition['carbohydrate'] ?? 0).round();
  int get totalProtein => (_currentTotalNutrition['protein'] ?? 0).round();
  int get totalFat => (_currentTotalNutrition['fat'] ?? 0).round();
  int get totalSugar => (_currentTotalNutrition['sugar'] ?? 0).round();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.originalRecord != null;

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
              title: Text(
                isEditMode ? '식단 정보 수정' : '식단 정보 확인',
                style: const TextStyle(
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
                    GestureDetector(
                      onTap: () => _showImagePicker(context),
                      child: Stack(
                        children: [
                          Container(
                            height: 280,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: _newImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: _buildPickedImage(_newImage!),
                                  )
                                : widget.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: _buildPickedImage(widget.image!),
                                  )
                                : (_networkImageUrl != null &&
                                      _networkImageUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.network(
                                      _networkImageUrl!,
                                      width: double.infinity,
                                      height: 280,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.fastfood,
                                      size: 64,
                                      color: Colors.orange,
                                    ),
                                  ),
                          ),
                          Positioned(
                            right: 15,
                            bottom: 15,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
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
                                  setState(() => selectedMeal = value!);
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
                      '식단 구성 (${_baseFoods.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: List.generate(_baseFoods.length, (index) {
                        return FoodItemCard(
                          item: _baseFoods[index],
                          quantity: quantities[index],
                          onChanged: (value) {
                            setState(() {
                              quantities[index] = value;
                            });
                          },
                          onNameChanged: (newName) {
                            setState(() {
                              _baseFoods[index] = FoodItem(
                                name: newName,
                                amountLabel: _baseFoods[index].amountLabel,
                                servingCount: _baseFoods[index].servingCount,
                                calories: _baseFoods[index].calories,
                                carbohydrate: _baseFoods[index].carbohydrate,
                                protein: _baseFoods[index].protein,
                                fat: _baseFoods[index].fat,
                                sugar: _baseFoods[index].sugar,
                              );
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    NutritionSummaryBox(
                      calories: totalCalories.round(),
                      carbohydrate: totalCarbohydrate,
                      protein: totalProtein,
                      fat: totalFat,
                      sugar: totalSugar,
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
                            : Text(
                                isEditMode ? '수정하기' : '저장하기',
                                style: const TextStyle(
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
