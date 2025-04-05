import 'package:flutter/material.dart';
import 'expense.dart';
import 'expense_dao.dart';
import 'database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase
      .databaseBuilder('expenses.db')
      .build();
  runApp(ExpenseApp(database.expenseDao));
}

class ExpenseApp extends StatelessWidget {
  final ExpenseDao dao;
  const ExpenseApp(this.dao, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: ExpenseHomePage(dao),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  final ExpenseDao dao;
  const ExpenseHomePage(this.dao, {super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final paymentCtrl = TextEditingController();
  int? editingId;
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadFromPrefs();
  }

  void _loadExpenses() async {
    final list = await widget.dao.findAllExpenses();
    setState(() {
      expenses = list;
    });
  }

  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('last_name', nameCtrl.text);
    prefs.setString('last_category', categoryCtrl.text);
    prefs.setString('last_amount', amountCtrl.text);
    prefs.setString('last_date', dateCtrl.text);
    prefs.setString('last_payment', paymentCtrl.text);
  }

  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameCtrl.text = prefs.getString('last_name') ?? '';
      categoryCtrl.text = prefs.getString('last_category') ?? '';
      amountCtrl.text = prefs.getString('last_amount') ?? '';
      dateCtrl.text = prefs.getString('last_date') ?? '';
      paymentCtrl.text = prefs.getString('last_payment') ?? '';
    });
  }

  void _addOrUpdateExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: editingId,
        name: nameCtrl.text,
        category: categoryCtrl.text,
        amount: double.parse(amountCtrl.text),
        date: dateCtrl.text,
        paymentMethod: paymentCtrl.text,
      );

      if (editingId == null) {
        await widget.dao.insertExpense(expense);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added!')),
        );
      } else {
        await widget.dao.updateExpense(expense);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated!')),
        );
        editingId = null;
      }

      _saveToPrefs();
      _clearFields();
      _loadExpenses();
    }
  }

  void _editExpense(Expense expense) {
    setState(() {
      editingId = expense.id;
      nameCtrl.text = expense.name;
      categoryCtrl.text = expense.category;
      amountCtrl.text = expense.amount.toString();
      dateCtrl.text = expense.date;
      paymentCtrl.text = expense.paymentMethod;
    });
  }

  void _deleteExpense(Expense expense) async {
    await widget.dao.deleteExpense(expense);
    _loadExpenses();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted.')),
    );
  }

  void _clearFields() {
    nameCtrl.clear();
    categoryCtrl.clear();
    amountCtrl.clear();
    dateCtrl.clear();
    paymentCtrl.clear();
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Instructions'),
        content: const Text('Enter expense details, then press Save. Tap item to edit, use delete to remove.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(icon: const Icon(Icons.help), onPressed: _showInstructions),
        ],
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Expense Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: paymentCtrl, decoration: const InputDecoration(labelText: 'Payment Method'), validator: (v) => v!.isEmpty ? 'Required' : null),
                ElevatedButton(
                  onPressed: _addOrUpdateExpense,
                  child: Text(editingId == null ? 'Add Expense' : 'Update Expense'),
                ),
              ]),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (_, i) {
                final exp = expenses[i];
                return ListTile(
                  title: Text('${exp.name} - \$${exp.amount.toStringAsFixed(2)}'),
                  subtitle: Text('${exp.category} | ${exp.date} | ${exp.paymentMethod}'),
                  onTap: () => _editExpense(exp),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteExpense(exp),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}