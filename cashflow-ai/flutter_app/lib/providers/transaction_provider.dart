import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<Transaction> _transactions = [];
  List<Transaction> _pendingTransactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  List<Transaction> get pendingTransactions => _pendingTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance {
    return _transactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalSpent {
    return _transactions
        .where((tx) => tx.amount < 0)
        .fold(0.0, (sum, tx) => sum + tx.amount.abs());
  }

  double get totalIncome {
    return _transactions
        .where((tx) => tx.amount > 0)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _databaseService.getAllTransactions();
      _pendingTransactions = await _databaseService.getPendingTransactions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncEmails({
    String? imapServer,
    String? emailAddress,
    String? appPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load from preferences if not provided
      final prefs = await SharedPreferences.getInstance();
      final server = imapServer ?? prefs.getString('imap_server') ?? 'imap.gmail.com';
      final email = emailAddress ?? prefs.getString('email_address') ?? '';
      final password = appPassword ?? prefs.getString('app_password') ?? '';

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email credentials not configured. Please set them in Settings.');
      }

      final transactions = await _apiService.syncEmails(
        imapServer: server,
        emailAddress: email,
        appPassword: password,
      );
      
      // Save to database
      for (var tx in transactions) {
        await _databaseService.insertTransaction(tx);
      }
      
      // Reload from database
      _pendingTransactions = await _databaseService.getPendingTransactions();
      _transactions = await _databaseService.getAllTransactions();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmTransaction(Transaction transaction) async {
    try {
      final updated = transaction.copyWith(isConfirmed: true);
      await _databaseService.updateTransaction(updated);
      _pendingTransactions.removeWhere((tx) => tx.id == transaction.id);
      _transactions.insert(0, updated);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTransactionCategory(
    String transactionId,
    String category,
  ) async {
    try {
      final index = _pendingTransactions.indexWhere((tx) => tx.id == transactionId);
      if (index != -1) {
        final updated = _pendingTransactions[index].copyWith(category: category);
        _pendingTransactions[index] = updated;
        await _databaseService.updateTransaction(updated);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _databaseService.deleteTransaction(transactionId);
      _pendingTransactions.removeWhere((tx) => tx.id == transactionId);
      _transactions.removeWhere((tx) => tx.id == transactionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _databaseService.insertTransaction(transaction);
      if (transaction.isConfirmed) {
        _transactions.insert(0, transaction);
      } else {
        _pendingTransactions.insert(0, transaction);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
