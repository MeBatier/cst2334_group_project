import 'package:floor/floor.dart';
import 'customer_item.dart';
import 'customer_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

part 'database.g.dart';

@Database(version: 1, entities: [CustomerItem])
abstract class AppDatabase extends FloorDatabase {
  CustomerDao get customerDao;
}