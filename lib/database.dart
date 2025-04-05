import 'dart:async';
import 'package:floor/floor.dart';
import 'expense.dart';
import 'expense_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart'; // ✅ This line is now correct

@Database(version: 1, entities: [Expense])
abstract class AppDatabase extends FloorDatabase {
  ExpenseDao get expenseDao;
}