import 'package:flutter/material.dart';
import 'package:dangdang/features/meal/domain/entities/meal_record.dart';
import 'package:dangdang/features/meal/data/services/meal_ai_service.dart';
import 'package:dangdang/features/meal/presentation/widgets/ai_analysis_card.dart';
import 'package:dangdang/core/widgets/common/state_views.dart';

class AiAnalysisBottomSheet extends StatefulWidget {
  final List<MealRecord> records;
  final String subtitle;

  const AiAnalysisBottomSheet({
    super.key,
    required this.records,
    required this.subtitle,
  });

  @override
  State<AiAnalysisBottomSheet> createState() => _AiAnalysisBottomSheetState();
}

class _AiAnalysisBottomSheetState extends State<AiAnalysisBottomSheet> {
  late Future<MealHabitAnalysisResult> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  void _loadAnalysis() {
    _analysisFuture = MealAiService().analyzeMealHabits(
      records: widget.records,
      scopeLabel: widget.subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.75,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EAF0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<MealHabitAnalysisResult>(
                  future: _analysisFuture,
                  builder: (context, snapshot) {
                    return ListView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      children: [
                        _buildAnalysisHeader(
                          context,
                          subtitle: widget.subtitle,
                          recordCount: widget.records.length,
                        ),
                        const SizedBox(height: 32),
                        if (snapshot.connectionState != ConnectionState.done)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const LoadingView(),
                                const SizedBox(height: 20),
                                Text(
                                  'AI 식단 분석중입니다...',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF3E4657),
                                      ),
                                ),
                              ],
                            ),
                          )
                        else if (snapshot.hasError)
                          ErrorMessageView(
                            errorMessage: '분석 결과를 불러오지 못했어요.',
                            onRetry: () {
                              setState(() {
                                _loadAnalysis();
                              });
                            },
                          )
                        else
                          _buildAnalysisSections(
                            context,
                            snapshot.data ??
                                const MealHabitAnalysisResult(
                                  patterns: [],
                                  recommendations: [],
                                ),
                          ),
                        if (snapshot.connectionState == ConnectionState.done &&
                            !snapshot.hasError) ...[
                          const SizedBox(height: 32),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6555FF), Color(0xFF8B5AFF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6555FF,
                                  ).withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => Navigator.pop(context),
                                child: Center(
                                  child: Text(
                                    '분석 내용 확인완료',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalysisHeader(
    BuildContext context, {
    required String subtitle,
    required int recordCount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5FF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF5A46F5),
            size: 38,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI 식단 건강 리포트',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF9AA1B4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisSections(
    BuildContext context,
    MealHabitAnalysisResult result,
  ) {
    final patterns = result.patterns.isEmpty
        ? const ['기록된 식단 수가 적어 뚜렷한 패턴을 찾지 못했어요.']
        : result.patterns;
    final recommendations = result.recommendations.isEmpty
        ? const ['기록이 더 쌓이면 더 구체적인 식단 추천을 드릴 수 있어요.']
        : result.recommendations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up_rounded, color: Color(0xFF5A46F5)),
            const SizedBox(width: 8),
            Text(
              '식습관 패턴',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...patterns.map(
          (pattern) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AiAnalysisCard(
              text: pattern,
              icon: Icons.circle,
              iconColor: const Color(0xFFB180FA),
              backgroundColor: const Color(0xFFF6F0FF),
              borderColor: const Color(0xFFEFE6FF),
              textColor: const Color(0xFF34177A),
              iconSize: 8,
              isPattern: true,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            const Icon(Icons.restaurant_outlined, color: Color(0xFF3CB043)),
            const SizedBox(width: 8),
            Text(
              'AI 추천',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...recommendations.map(
          (recommendation) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AiAnalysisCard(
              text: recommendation,
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF4CB158),
              backgroundColor: const Color(0xFFF9FFFA),
              borderColor: const Color(0xFFE5F7E8),
              textColor: const Color(0xFF1B4021),
              iconSize: 22,
              isPattern: false,
            ),
          ),
        ),
      ],
    );
  }
}
