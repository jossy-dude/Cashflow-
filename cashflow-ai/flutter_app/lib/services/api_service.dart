import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  Future<List<Transaction>> syncEmails({
    required String imapServer,
    required String emailAddress,
    required String appPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imap_server': imapServer,
          'email_address': emailAddress,
          'app_password': appPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> transactionsJson = data['transactions'] ?? [];
        return transactionsJson
            .map((json) => Transaction.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to sync: ${response.body}');
      }
    } catch (e) {
      throw Exception('Sync error: $e');
    }
  }

  Future<bool> testConnection({
    required String imapServer,
    required String emailAddress,
    required String appPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/test-connection'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imap_server': imapServer,
          'email_address': emailAddress,
          'app_password': appPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
