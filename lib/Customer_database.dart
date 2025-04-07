import 'package:floor/floor.dart';
import 'customer_item.dart';
import 'customer_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

part 'database.g.dart';
/// The main database class for the application.
///
/// This class is annotated with Database from the `floor` package to define
/// the version and list of entity classes. Floor generates the implementation
/// for this abstract class in `database.g.dart`.
///
/// Currently, it holds a single entity: [CustomerItem], and exposes
/// a [CustomerDao] instance for performing database operations.
@Database(version: 1, entities: [CustomerItem])
abstract class AppDatabase extends FloorDatabase {
  CustomerDao get customerDao;
}