import 'package:flutter/material.dart';
import 'package:dangdang/core/widgets/common/state_views.dart';

class AiAnalysisBottomSheet<T> extends StatefulWidget {
  final Future<T> analysisFuture;
  final String title;
  final String subtitle;
  final Widget Function(BuildContext context, T data) analysisBuilder;
  final String loadingMessage;

  const AiAnalysisBottomSheet({
    super.key,
    required this.analysisFuture,
    required this.title,
    required this.subtitle,
    required this.analysisBuilder,
    this.loadingMessage = 'AI 분석중입니다...',
  });

  @override
  State<AiAnalysisBottomSheet<T>> createState() =>
      _AiAnalysisBottomSheetState<T>();
}

class _AiAnalysisBottomSheetState<T> extends State<AiAnalysisBottomSheet<T>> {
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
                child: FutureBuilder<T>(
                  future: widget.analysisFuture,
                  builder: (context, snapshot) {
                    return ListView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      children: [
                        _buildAnalysisHeader(
                          context,
                          title: widget.title,
                          subtitle: widget.subtitle,
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
                                  widget.loadingMessage,
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
                              if (mounted) setState(() {});
                            },
                          )
                        else if (snapshot.hasData)
                          widget.analysisBuilder(context, snapshot.data as T),
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
    required String title,
    required String subtitle,
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
                title,
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
}
