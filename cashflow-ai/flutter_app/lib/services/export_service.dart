import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';
import 'database_service.dart';

class ExportService {
  static final ExportService instance = ExportService._init();
  ExportService._init();

  final DatabaseService _db = DatabaseService.instance;

  Future<String> exportToCSV({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    try {
      // Get transactions
      List<Transaction> transactions;
      if (startDate != null || endDate != null || category != null) {
        transactions = await _getFilteredTransactions(
          startDate: startDate,
          endDate: endDate,
          category: category,
        );
      } else {
        transactions = await _db.getAllTransactions();
      }

      // Convert to CSV
      final csvData = <List<dynamic>>[
        [
          'ID',
          'Date',
          'Time',
          'Amount (ETB)',
          'Type',
          'Category',
          'Title',
          'Account Name',
          'Account Number',
          'VAT',
          'Service Fee',
          'Transaction ID',
          'Tags',
          'Notes',
        ],
      ];

      for (var tx in transactions) {
        csvData.add([
          tx.id,
          tx.date,
          tx.time,
          tx.amount,
          tx.type,
          tx.category,
          tx.title,
          tx.accountName,
          tx.accountNumber,
          tx.vat,
          tx.serviceFee,
          tx.transactionId,
          tx.tags,
          tx.notes.replaceAll('\n', ' '),
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'cashflow_export_$timestamp.csv';
      final file = File('${exportDir.path}/$fileName');
      await file.writeAsString(csvString);

      // Save export record to database
      await _saveExportRecord(fileName, file.path, transactions.length);

      return file.path;
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  Future<List<Transaction>> _getFilteredTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    final allTransactions = await _db.getAllTransactions();
    
    return allTransactions.where((tx) {
      if (startDate != null) {
        final txDate = DateTime.parse(tx.date);
        if (txDate.isBefore(startDate)) return false;
      }
      if (endDate != null) {
        final txDate = DateTime.parse(tx.date);
        if (txDate.isAfter(endDate)) return false;
      }
      if (category != null && tx.category != category) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _saveExportRecord(String fileName, String filePath, int recordCount) async {
    final db = await _db.database;
    await db.insert('export_history', {
      'file_name': fileName,
      'file_path': filePath,
      'record_count': recordCount,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getExportHistory() async {
    final db = await _db.database;
    
    // Create table if not exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS export_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        record_count INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    return await db.query('export_history', orderBy: 'created_at DESC');
  }

  Future<int> getTotalStorageSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/exports');
      
      if (!await exportDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (var entity in exportDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/exports');
      
      if (await exportDir.exists()) {
        await exportDir.delete(recursive: true);
      }
      
      // Clear export history
      final db = await _db.database;
      await db.delete('export_history');
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  Future<void> deleteExport(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Remove from history
      final db = await _db.database;
      await db.delete('export_history', where: 'file_path = ?', whereArgs: [filePath]);
    } catch (e) {
      throw Exception('Failed to delete export: $e');
    }
  }
}
