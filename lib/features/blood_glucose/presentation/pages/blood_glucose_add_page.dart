import 'package:flutter/material.dart';
import '../widgets/blood_glucose_form.dart';

class BloodSugarAddPage extends StatelessWidget {
  const BloodSugarAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BloodSugarForm(
      title: '새 기록 추가',
      buttonText: '기록 저장하기',
    );
  }
}