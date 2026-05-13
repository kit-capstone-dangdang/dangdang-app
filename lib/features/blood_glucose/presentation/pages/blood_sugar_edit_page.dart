import 'package:flutter/material.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_sugar_record.dart';
import '../widgets/blood_sugar_form.dart';

class BloodSugarEditPage extends StatelessWidget {
  final BloodSugarRecord record;

  const BloodSugarEditPage({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return BloodSugarForm(
      title: '기록 수정',
      buttonText: '수정 완료',
      initialRecord: record,
    );
  }
}