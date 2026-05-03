import 'package:flutter/material.dart';

// ==========================================
// 1. 로딩 화면 (LoadingView)
// ==========================================
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Color(0xFF2F69FE), // 당당하게 메인 컬러
        ),
      ),
    );
  }
}

// ==========================================
// 2. 에러 메시지 UI (ErrorMessageView)
// ==========================================
class ErrorMessageView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorMessageView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("다시 시도"),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. 데이터 없을 때 빈 화면 (EmptyStateView)
// ==========================================
class EmptyStateView extends StatelessWidget {
  final String message;

  const EmptyStateView({
    super.key,
    this.message = "식단 기록이 없습니다.\n첫 식단을 기록해보세요!",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 80),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. 분석 중 상태 화면 (AI 오버레이)
// ==========================================
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child, // 실제 화면 콘텐츠
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2F69FE), // 당당하게 메인 컬러
                    ),
                    strokeWidth: 4.0,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "AI가 분석 중입니다...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "잠시만 기다려주세요",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ==========================================
// 5. 스켈레톤 UI (기존 SkeletonItem - 필요시 활용)
// ==========================================
class SkeletonItem extends StatelessWidget {
  const SkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(width: 150, height: 12, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
