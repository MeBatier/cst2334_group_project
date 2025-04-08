// File Name: maintenance_dao.dart
// Name: Kenil Patel
// Student id: 041127140
// Course and Section: CST2335 031
// Date: April 8, 2025
// Purpose: Defines DAO methods for managing and accessing database maintenance records.

import 'package:floor/floor.dart';
import '../model/maintenance_record.dart';

@dao
abstract class MaintenanceDao {
  // get all maintenance records from the database
  @Query('SELECT * FROM MaintenanceRecord')
  Future<List<MaintenanceRecord>> getAllRecords();

  // Insert a new maintenance record
  @insert
  Future<void> insertRecord(MaintenanceRecord record);

  // Update an existing maintenance record
  @update
  Future<void> updateRecord(MaintenanceRecord record);

  // Delete a maintenance record
  @delete
  Future<void> deleteRecord(MaintenanceRecord record);
}
// By Kenil Patel
