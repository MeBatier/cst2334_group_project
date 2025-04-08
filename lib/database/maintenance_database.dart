// File Name: maintenance_database.dart
// Name: Kenil Patel
// Student id: 041127140
// Course and Section: CST2335 031
// Date: April 8, 2025
// Purpose: Builds the Floor database and grants DAO access to the maintenance logs.

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../model/maintenance_record.dart';
import 'maintenance_dao.dart';

// Generated code will be part of this file
part 'maintenance_database.g.dart';

// Main database definition with version and entities
@Database(version: 1, entities: [MaintenanceRecord])
abstract class MaintenanceDatabase extends FloorDatabase {
  // Accessor to the DAO
  MaintenanceDao get maintenanceDao;
}
// By Kenil Patel
