import 'package:floor/floor.dart';
import '../expense.dart';

@dao
abstract class ExpenseDao {
  @Query('SELECT * FROM Expense')
  Future<List<Expense>> findAllExpenses();

  @insert
  Future<void> insertExpense(Expense expense);

  @update
  Future<void> updateExpense(Expense expense);

  @delete
  Future<void> deleteExpense(Expense expense);
}