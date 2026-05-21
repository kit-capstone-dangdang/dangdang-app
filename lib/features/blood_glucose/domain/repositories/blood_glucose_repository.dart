import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_record.dart';

abstract class BloodSugarRepository {
  Future<void> createRecord(BloodGlucoseRecord record);

  Future<List<BloodGlucoseRecord>> getRecords();

  Future<void> updateRecord(BloodGlucoseRecord record);

  Future<void> deleteRecord(String id);
}
