import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_record.dart';

abstract class BloodSugarRepository {
  Future<void> createRecord(
    BloodSugarRecord record,
  );

  Future<List<BloodSugarRecord>> getRecords();

  Future<void> updateRecord(
    BloodSugarRecord record,
  );

  Future<void> deleteRecord(String id);
}