import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/common/custom_card.dart';
import 'dart:io';
import '../widgets/meal_analysis_result/food_detail_item_card.dart';

class AnalysisResult extends StatelessWidget {
  final XFile? image;
  final Map<String, dynamic> result;

  const AnalysisResult({super.key, required this.result, required this.image});

  @override
  Widget build(BuildContext context) {
    final foods = result['foods'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              toolbarHeight: 70,
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                ),
              ),
              title: const Text(
                '분석 결과',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              centerTitle: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 음식 사진 영역
                    CustomCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 38,
                      backgroundColor: Colors.grey.shade200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(38),
                        child: Image.file(
                          File(image!.path),
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 인식된 음식 타이틀
                    Text(
                      '인식된 음식 (${foods.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 음식 아이템 리스트
                    ...foods.map((food) {
                      return FoodDetailItemCard(
                        item: food as Map<String, dynamic>,
                      );
                    }),

                    const SizedBox(height: 10),

                    // 상세 수정 및 저장
                    CustomCard(
                      backgroundColor: const Color(0xFF2F69FE),
                      showShadow: false,
                      onTap: () {
                        // TODO: 저장 기능
                      },
                      child: const Center(
                        child: Text(
                          '상세 수정 및 저장',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 다시 촬영하기
                    CustomCard(
                      showShadow: false,
                      border: Border.all(color: Colors.grey.shade300),
                      onTap: () => Navigator.pop(context),
                      child: const Center(
                        child: Text(
                          '다시 촬영하기',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
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
