import 'package:floor/floor.dart';
import '../model/maintenance_record.dart';

@dao
abstract class MaintenanceDao {
  @Query('SELECT * FROM MaintenanceRecord')
  Future<List<MaintenanceRecord>> getAllRecords();

  @insert
  Future<void> insertRecord(MaintenanceRecord record);

  @update
  Future<void> updateRecord(MaintenanceRecord record);

  @delete
  Future<void> deleteRecord(MaintenanceRecord record);
}
