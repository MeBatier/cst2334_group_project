import 'package:floor/floor.dart';

@entity
class Expense {
  @primaryKey
  final int? id;

  final String name;
  final String category;
  final double amount;
  final String date;
  final String paymentMethod;

  Expense({
    this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMethod,
  });
}