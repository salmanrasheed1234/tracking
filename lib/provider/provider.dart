// ignore_for_file: avoid_print

import 'dart:async';

import 'package:tracking/exports/exports.dart';

class ExpenseProvider with ChangeNotifier {
  late Box<Expense> _expenseBox;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  StreamSubscription<List<Expense>>? _firebaseSubscription;

  ExpenseProvider() {
    _initializeFirebaseListener();
  }

  bool get isLoading => _isLoading;
  List<Expense> get expenses => _expenses;
  double get totalSpending =>
      _expenses.fold(0, (sum, item) => sum + item.amount);

  Future<void> init() async {
    _expenseBox = Hive.box<Expense>('expensesBox');
    _isLoading = true;
    notifyListeners();
    await _initializeFirebaseListener();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _initializeFirebaseListener() async {
    _firebaseSubscription = Expense.getAllExpenses().listen((expenses) {
      _expenses = expenses;
      _syncWithLocal();
      notifyListeners();
    });
  }

  void _syncWithLocal() {
    // Sync Firestore data with local storage
    _expenseBox.clear();
    for (var expense in _expenses) {
      _expenseBox.add(expense);
    }
  }

  Future<void> addExpense(Expense expense) async {
    _isLoading = true;
    notifyListeners();

    try {
      await expense.saveToFirestore();
      _expenseBox.add(expense);
    } catch (e) {
      print('Error adding expense: $e');
      // Add only to local storage if Firestore fails
      _expenseBox.add(expense);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeExpense(Expense expense) async {
    _isLoading = true;
    notifyListeners();

    try {
      await expense.deleteFromFirestore();
      await expense.delete(); // Delete from Hive
    } catch (e) {
      print('Error removing expense: $e');
      // Delete from local storage even if Firestore fails
      await expense.delete();
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _firebaseSubscription?.cancel();
    super.dispose();
  }
}
