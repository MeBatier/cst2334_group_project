import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../model/maintenance_record.dart';
import 'maintenance_dao.dart';

part 'maintenance_database.g.dart'; // This will be generated

@Database(version: 1, entities: [MaintenanceRecord])
abstract class MaintenanceDatabase extends FloorDatabase {
  MaintenanceDao get maintenanceDao;
}
