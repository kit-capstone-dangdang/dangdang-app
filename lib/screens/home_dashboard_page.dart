import 'package:dangdang/features/image_input/image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/common/custom_icon.dart';
import '../services/gemini_service.dart';
import '../screens/analysis_result.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

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
            borderRadius: BorderRadius.only(
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
                  Navigator.pop(parentContext);

                  final XFile? image = await imagePickerService
                      .pickFromCamera();

                  if (image != null && parentContext.mounted) {
                    try {
                      final geminiService = GeminiService();

                      final result = await geminiService.analyzeFoodImage(
                        image,
                      );

                      if (!parentContext.mounted) return;

                      Navigator.push(
                        parentContext,
                        MaterialPageRoute(
                          builder: (context) =>
                              AnalysisResult(image: image, result: result),
                        ),
                      );
                    } catch (e) {
                      // 에러 처리: 스낵바로 에러 메시지 표시
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text('분석 중 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
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
                  Navigator.pop(parentContext);

                  final XFile? image = await imagePickerService
                      .pickFromGallery();

                  if (image != null && parentContext.mounted) {
                    try {
                      final geminiService = GeminiService();

                      final result = await geminiService.analyzeFoodImage(
                        image,
                      );

                      if (!parentContext.mounted) return;

                      Navigator.push(
                        parentContext,
                        MaterialPageRoute(
                          builder: (context) =>
                              AnalysisResult(image: image, result: result),
                        ),
                      );
                    } catch (e) {
                      // 에러 처리: 스낵바로 에러 메시지 표시
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text('분석 중 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
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
                  backgroundColor: colorScheme.surfaceVariant,
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: colorScheme.surface,
              surfaceTintColor: colorScheme.surface,
              toolbarHeight: 90,
              automaticallyImplyLeading: false,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '안녕하세요, 김당뇨님!',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '오늘도 건강한 하루 되세요.',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFE8F0FE),
                    child: Text(
                      '김',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCard(
                      padding: const EdgeInsets.all(25),
                      borderRadius: 25,
                      backgroundColor: const Color(0xFF2F69FE),
                      showShadow: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5B8EFF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '최근 혈당',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.trending_up,
                                color: colorScheme.onPrimary,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '105',
                                style: textTheme.displayMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'mg/dL',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '✓ 정상 범위 내에 있습니다 (공복)',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: CustomCard(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('혈당 기록 화면으로 이동합니다.'),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIcon(
                                  icon: Icons.add,
                                  backgroundColor: const Color(0xFFE8F0FE),
                                  iconColor: colorScheme.primary,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  '혈당 기록',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CustomCard(
                            onTap: () {
                              _showDietCaptureBottomSheet(context);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIcon(
                                  icon: Icons.camera_alt_outlined,
                                  backgroundColor: const Color(0xFFE8FAF1),
                                  iconColor: const Color(0xFF12B76A),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  '식단 촬영',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '혈당 리포트',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: 상세 리포트 페이지로 이동
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                '자세히 보기',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomCard(
                          child: SizedBox(
                            height: 110,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                '그래프 영역 (그래프 패키지 필요)',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
