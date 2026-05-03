import 'package:dangdang/widgets/common/state_views.dart';
import 'package:flutter/material.dart';

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  State<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  // Mock 상태 관리 변수들
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDataLoaded = false;

  void _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. 데이터 불러오는 시뮬레이션 (2초 대기)
      await Future.delayed(const Duration(seconds: 2));

      // 에러 화면을 테스트하고 싶다면 아래 주석을 풀어보세요!
      // throw Exception("네트워크 연결이 원활하지 않습니다.");

      setState(() {
        _isLoading = false;
        _isDataLoaded = true; // 로딩 끝! 데이터 표시 시작!
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("당당하게 건강 데이터")),
      body: LoadingOverlay(isLoading: _isLoading, child: _buildBody()),
      // 오른쪽 아래 다운로드 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        child: const Icon(Icons.download),
      ),
    );
  }

  Widget _buildBody() {
    // 2. 에러 상황 처리
    if (_errorMessage != null) {
      return ErrorMessageView(
        errorMessage: _errorMessage!,
        onRetry: _fetchData,
      );
    }

    // 3. 처음에 아무것도 없을 때 (데이터 로딩 전)
    if (!_isDataLoaded && !_isLoading) {
      return const Center(child: Text("버튼을 눌러 AI 분석을 시작해보세요."));
    }

    // 4. 드디어 완성된 결과 화면! (음식 양 조절 리스트)
    if (_isDataLoaded) {
      return ListView(
        padding: const EdgeInsets.only(top: 20),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "AI 식단 분석 결과",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          // 아래처럼 원하는 음식을 계속 추가할 수 있어요!
          FoodResultCard(
            foodName: "비빔밥",
            baseCalories: 500,
            initialPortion: 1.0,
          ),
          FoodResultCard(
            foodName: "된장국",
            baseCalories: 150,
            initialPortion: 0.5,
          ),
          FoodResultCard(
            foodName: "계란말이",
            baseCalories: 120,
            initialPortion: 1.0,
          ),
        ],
      );
    }

    // 5. 로딩 중일 때 백그라운드에 깔릴 기본 화면 (혹은 스켈레톤)
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => const SkeletonItem(),
    );
  }
}

class FoodResultCard extends StatefulWidget {
  final String foodName;
  final double initialPortion;
  final int baseCalories;

  const FoodResultCard({
    super.key,
    required this.foodName,
    this.initialPortion = 1.0,
    required this.baseCalories,
  });

  @override
  State<FoodResultCard> createState() => _FoodResultCardState();
}

// ==========================================
// 식단 결과 카드 알맹이 (0.1인분 조절 로직)
// ==========================================
class _FoodResultCardState extends State<FoodResultCard> {
  late double _currentPortion;

  @override
  void initState() {
    super.initState();
    _currentPortion = widget.initialPortion;
  }

  // - 버튼 (0.1인분 감소)
  void _decreasePortion() {
    if (_currentPortion > 0.1) {
      setState(() {
        _currentPortion = double.parse(
          (_currentPortion - 0.1).toStringAsFixed(1),
        );
      });
    }
  }

  // + 버튼 (0.1인분 증가)
  void _increasePortion() {
    setState(() {
      _currentPortion = double.parse(
        (_currentPortion + 0.1).toStringAsFixed(1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalCalories = (widget.baseCalories * _currentPortion).round();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.foodName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$totalCalories kcal",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: _currentPortion > 0.1 ? _decreasePortion : null,
                    color: const Color(0xFF2F69FE),
                  ),
                  Text(
                    "${_currentPortion.toStringAsFixed(1)}인분",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: _increasePortion,
                    color: const Color(0xFF2F69FE),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
