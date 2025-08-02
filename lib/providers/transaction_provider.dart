import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/csv_service.dart';
import '../constants/app_constants.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final CsvService _csvService = CsvService();

  List<Transaction> _transactions = [];
  List<Transaction> _currentMonthTransactions = [];
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _balance = 0.0;
  Map<String, double> _expenseCategoryTotals = {};
  Map<String, double> _incomeCategoryTotals = {};
  
  DateTime _selectedDate = DateTime.now();

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get currentMonthTransactions => _currentMonthTransactions;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get balance => _balance;
  Map<String, double> get expenseCategoryTotals => _expenseCategoryTotals;
  Map<String, double> get incomeCategoryTotals => _incomeCategoryTotals;
  DateTime get selectedDate => _selectedDate;

  // Initialize provider
  Future<void> initialize() async {
    await loadTransactions();
    await loadCurrentMonthData();
  }

  // Load all transactions
  Future<void> loadTransactions() async {
    _transactions = await _databaseService.getAllTransactions();
    notifyListeners();
  }

  // Load current month data
  Future<void> loadCurrentMonthData() async {
    await loadMonthData(_selectedDate.year, _selectedDate.month);
  }

  // Load data for specific month
  Future<void> loadMonthData(int year, int month) async {
    _selectedDate = DateTime(year, month);
    _currentMonthTransactions = await _databaseService.getTransactionsByMonth(year, month);
    _totalIncome = await _databaseService.getTotalIncome(year, month);
    _totalExpenses = await _databaseService.getTotalExpenses(year, month);
    _balance = _totalIncome - _totalExpenses;
    _expenseCategoryTotals = await _databaseService.getCategoryTotals(year, month, TransactionType.expense);
    _incomeCategoryTotals = await _databaseService.getCategoryTotals(year, month, TransactionType.income);
    notifyListeners();
  }

  // Add transaction
  Future<void> addTransaction(Transaction transaction) async {
    await _databaseService.insertTransaction(transaction);
    await loadTransactions();
    await loadCurrentMonthData();
  }

  // Update transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await _databaseService.updateTransaction(transaction);
    await loadTransactions();
    await loadCurrentMonthData();
  }

  // Delete transaction
  Future<void> deleteTransaction(int id) async {
    await _databaseService.deleteTransaction(id);
    await loadTransactions();
    await loadCurrentMonthData();
  }

  // Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _currentMonthTransactions.where((t) => t.type == type).toList();
  }

  // Get transactions by payment method
  List<Transaction> getTransactionsByPaymentMethod(PaymentMethod method) {
    return _currentMonthTransactions.where((t) => t.paymentMethod == method).toList();
  }

  // Export current month to CSV
  Future<String> exportCurrentMonthToCsv() async {
    return await _csvService.exportTransactionsToCsv(
      _currentMonthTransactions,
      _selectedDate.year,
      _selectedDate.month,
    );
  }

  // Export all transactions to CSV
  Future<String> exportAllTransactionsToCsv() async {
    return await _csvService.exportAllTransactionsToCsv(_transactions);
  }

  // Navigate to previous month
  Future<void> previousMonth() async {
    final newDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    await loadMonthData(newDate.year, newDate.month);
  }

  // Navigate to next month
  Future<void> nextMonth() async {
    final newDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    await loadMonthData(newDate.year, newDate.month);
  }

  // Get formatted month year string
  String get monthYearString {
    return DateFormat('MMMM yyyy').format(_selectedDate);
  }

  // Get formatted balance string
  String get formattedBalance {
    return '\$${_balance.toStringAsFixed(2)}';
  }

  // Get formatted income string
  String get formattedIncome {
    return '\$${_totalIncome.toStringAsFixed(2)}';
  }

  // Get formatted expenses string
  String get formattedExpenses {
    return '\$${_totalExpenses.toStringAsFixed(2)}';
  }

  // Set current month for swipe navigation
  Future<void> setCurrentMonth(DateTime date) async {
    await loadMonthData(date.year, date.month);
  }

  // Import transactions from CSV
  Future<void> importFromCsv(String filePath) async {
    try {
      print('Starting CSV import from: $filePath');
      final transactions = await _csvService.importTransactionsFromCsv(filePath);
      
      print('CSV import completed. Found ${transactions.length} transactions');
      
      // Add all imported transactions to the database
      for (int i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        print('Inserting transaction ${i + 1}/${transactions.length}: ${transaction.category} - ${transaction.amount}');
        await _databaseService.insertTransaction(transaction);
      }
      
      print('All transactions inserted into database');
      
      // Reload data
      await loadTransactions();
      await loadCurrentMonthData();
      
      print('Data reloaded successfully');
    } catch (e) {
      print('Import failed: $e');
      throw Exception('Failed to import CSV: $e');
    }
  }
} 