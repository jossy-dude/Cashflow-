import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cashflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        account_name TEXT NOT NULL,
        account_number TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        type TEXT,
        category TEXT NOT NULL,
        title TEXT,
        notes TEXT,
        link TEXT,
        error TEXT,
        vat REAL DEFAULT 0,
        service_fee REAL DEFAULT 0,
        tags TEXT,
        transaction_id TEXT,
        confidence REAL DEFAULT 0,
        email_id TEXT,
        raw_email TEXT,
        is_confirmed INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        monthly_budget REAL DEFAULT 0,
        color INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Export history table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS export_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        record_count INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Insert default categories
    final defaultCategories = [
      {'id': '1', 'name': 'Food', 'icon': 'restaurant', 'monthly_budget': 0, 'color': 0xFFFF9800},
      {'id': '2', 'name': 'Transport', 'icon': 'directions_car', 'monthly_budget': 0, 'color': 0xFF2196F3},
      {'id': '3', 'name': 'Rent', 'icon': 'home', 'monthly_budget': 0, 'color': 0xFF9C27B0},
      {'id': '4', 'name': 'Shopping', 'icon': 'shopping_bag', 'monthly_budget': 0, 'color': 0xFFE91E63},
      {'id': '5', 'name': 'Other', 'icon': 'category', 'monthly_budget': 0, 'color': 0xFF607D8B},
    ];

    for (var cat in defaultCategories) {
      await db.insert('categories', {
        ...cat,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // Transaction operations
  Future<void> insertTransaction(Transaction transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'created_at DESC');
    return maps.map((map) => Transaction.fromJson(map)).toList();
  }

  Future<List<Transaction>> getPendingTransactions() async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'is_confirmed = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Transaction.fromJson(map)).toList();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Category operations
  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((map) => Category.fromJson(map)).toList();
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update(
      'categories',
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
