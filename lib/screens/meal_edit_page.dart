import 'package:flutter/material.dart';

class MealEditPage extends StatefulWidget {
  const MealEditPage({super.key});

  @override
  State<MealEditPage> createState() => _MealEditPageState();
}

class _MealEditPageState extends State<MealEditPage> {
  // 1. 상태 관리 변수 (0.1 단위 조절을 위한 변수)
  double _bibimbapPortion = 1.0;
  double _soupPortion = 1.0;

  final int _baseBibimbapCal = 560;
  final int _baseSoupCal = 90;

  // 0.1인분 감소 함수
  void _decreasePortion(String food, double current) {
    if (current > 0.1) {
      setState(() {
        if (food == 'bibimbap') {
          _bibimbapPortion = double.parse((current - 0.1).toStringAsFixed(1));
        } else {
          _soupPortion = double.parse((current - 0.1).toStringAsFixed(1));
        }
      });
    }
  }

  // 0.1인분 증가 함수
  void _increasePortion(String food, double current) {
    setState(() {
      if (food == 'bibimbap') {
        _bibimbapPortion = double.parse((current + 0.1).toStringAsFixed(1));
      } else {
        _soupPortion = double.parse((current + 0.1).toStringAsFixed(1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 실시간 칼로리 계산
    final int currentBibimbapCal = (_baseBibimbapCal * _bibimbapPortion)
        .round();
    final int currentSoupCal = (_baseSoupCal * _soupPortion).round();
    final int totalCalories = currentBibimbapCal + currentSoupCal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '식단 정보 확인',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상단 이미지 영역
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 180,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. 식사 구분 & 시간 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('식사 구분', style: TextStyle(fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '야식',
                              style: TextStyle(
                                color: Color(0xFF2F69FE),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFF2F69FE),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('기록 시간', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          Text(
                            '2026-04-27',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.calendar_today, size: 16),
                          SizedBox(width: 12),
                          Text(
                            '오후 02:18',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.access_time, size: 16),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. 식단 구성 타이틀
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '식단 구성 (2)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '섭취량 조절 가능',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. 비빔밥 조절 카드
            _buildFoodEditCard(
              foodName: '비빔밥',
              unit: '그릇',
              baseCalories: _baseBibimbapCal,
              currentPortion: _bibimbapPortion,
              onDecrease: () => _decreasePortion('bibimbap', _bibimbapPortion),
              onIncrease: () => _increasePortion('bibimbap', _bibimbapPortion),
            ),
            const SizedBox(height: 16),

            // 5. 된장국 조절 카드
            _buildFoodEditCard(
              foodName: '된장국',
              unit: '공기',
              baseCalories: _baseSoupCal,
              currentPortion: _soupPortion,
              onDecrease: () => _decreasePortion('soup', _soupPortion),
              onIncrease: () => _increasePortion('soup', _soupPortion),
            ),
            const SizedBox(height: 32),

            // 6. 파란색 총 영양 정보 박스
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2F69FE), // 당당하게 메인 블루 컬러
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총 영양 정보 합계',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        '${totalCalories} kcal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NutritionStat(label: '탄수', value: '97g'),
                      _NutritionStat(label: '단백', value: '24g'),
                      _NutritionStat(label: '지방', value: '14g'),
                      _NutritionStat(label: '당류', value: '16g'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 7. 식단 저장하기 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // 💡 변경된 '총 칼로리' 데이터를 담아서 보냄
                  Navigator.pop(context, {'updatedCalories': totalCalories});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F69FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '식단 저장하기',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 음식 아이템 카드 공통 위젯 분리 (코드 깔끔하게 유지!)
  Widget _buildFoodEditCard({
    required String foodName,
    required String unit,
    required int baseCalories,
    required double currentPortion,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    final int currentCal = (baseCalories * currentPortion).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${currentCal} kcal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F69FE),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.delete_outline, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // + / - 0.1 조절 컨트롤러 영역 (시안과 똑같이 넓게!)
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF), // 아주 연한 파란색 배경
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Color(0xFF2F69FE)),
                  onPressed: currentPortion > 0.1 ? onDecrease : null,
                ),
                Text(
                  '${currentPortion.toStringAsFixed(1)} $unit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F69FE),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF2F69FE)),
                  onPressed: onIncrease,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 하단 파란 박스 안의 영양소 텍스트용 미니 위젯
class _NutritionStat extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
