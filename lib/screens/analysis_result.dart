import 'package:dangdang/data/food_analysis_result_dummy_data.dart';
import 'package:flutter/material.dart';


class AnalysisResult extends StatelessWidget {
  const AnalysisResult({super.key});

  @override
  Widget build(BuildContext context) {
    const result = dummyFoodAnalysisResult;

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
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 64,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 인식된 음식 타이틀
                    Text(
                      '인식된 음식 (${result.items.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 음식 아이템 리스트
                    ...result.items.map(
                      (item) => Container(
                        padding: const EdgeInsets.all(22),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  item.servingText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${item.calories} kcal',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2F69FE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 상세 수정 및 저장
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F69FE),
                        borderRadius: BorderRadius.circular(30),
                      ),
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
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
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



