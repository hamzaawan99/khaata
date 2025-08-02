import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../constants/app_constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static sqlite.Database? _database;

  Future<sqlite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sqlite.Database> _initDatabase() async {
    String path = join(await sqlite.getDatabasesPath(), 'khaata.db');
    return await sqlite.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(sqlite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        type INTEGER NOT NULL,
        paymentMethod INTEGER NOT NULL,
        date TEXT NOT NULL,
        icon TEXT
      )
    ''');
  }

  // Insert transaction
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // Get transactions by month
  Future<List<Transaction>> getTransactionsByMonth(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: "strftime('%Y', date) = ? AND strftime('%m', date) = ?",
      whereArgs: [year.toString(), month.toString().padLeft(2, '0')],
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // Get transactions by type
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.index],
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // Get transactions by payment method
  Future<List<Transaction>> getTransactionsByPaymentMethod(PaymentMethod method) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'paymentMethod = ?',
      whereArgs: [method.index],
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // Update transaction
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete transaction
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total income for a month
  Future<double> getTotalIncome(int year, int month) async {
    final transactions = await getTransactionsByMonth(year, month);
    double total = 0.0;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        total += transaction.amount;
      }
    }
    return total;
  }

  // Get total expenses for a month
  Future<double> getTotalExpenses(int year, int month) async {
    final transactions = await getTransactionsByMonth(year, month);
    double total = 0.0;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        total += transaction.amount;
      }
    }
    return total;
  }

  // Get balance for a month
  Future<double> getBalance(int year, int month) async {
    final income = await getTotalIncome(year, month);
    final expenses = await getTotalExpenses(year, month);
    return income - expenses;
  }

  // Get category totals for a month
  Future<Map<String, double>> getCategoryTotals(int year, int month, TransactionType type) async {
    final transactions = await getTransactionsByMonth(year, month);
    final filteredTransactions = transactions.where((t) => t.type == type);
    
    Map<String, double> categoryTotals = {};
    for (var transaction in filteredTransactions) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    
    return categoryTotals;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
} 