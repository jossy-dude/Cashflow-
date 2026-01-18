class Transaction {
  final String id;
  final double amount;
  final String accountName;
  final String accountNumber;
  final String date;
  final String time;
  final String type; // 'debit', 'credit', or ''
  final String category;
  final String title; // Counterparty name
  final String notes;
  final String link;
  final String error;
  final double vat;
  final double serviceFee;
  final String tags;
  final String transactionId;
  final double confidence;
  final String emailId;
  final String rawEmail;
  final bool isConfirmed;

  Transaction({
    required this.id,
    required this.amount,
    required this.accountName,
    required this.accountNumber,
    required this.date,
    required this.time,
    required this.type,
    required this.category,
    required this.title,
    required this.notes,
    required this.link,
    required this.error,
    required this.vat,
    required this.serviceFee,
    required this.tags,
    required this.transactionId,
    required this.confidence,
    required this.emailId,
    required this.rawEmail,
    this.isConfirmed = false,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      accountName: json['account_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? 'undefined',
      title: json['title'] ?? '',
      notes: json['notes'] ?? '',
      link: json['link'] ?? '',
      error: json['error'] ?? '',
      vat: (json['vat'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (json['service_fee'] as num?)?.toDouble() ?? 0.0,
      tags: json['tags'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      emailId: json['email_id'] ?? '',
      rawEmail: json['raw_email'] ?? '',
      isConfirmed: (json['is_confirmed'] as int?) == 1 || json['is_confirmed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'account_name': accountName,
      'account_number': accountNumber,
      'date': date,
      'time': time,
      'type': type,
      'category': category,
      'title': title,
      'notes': notes,
      'link': link,
      'error': error,
      'vat': vat,
      'service_fee': serviceFee,
      'tags': tags,
      'transaction_id': transactionId,
      'confidence': confidence,
      'email_id': emailId,
      'raw_email': rawEmail,
      'is_confirmed': isConfirmed ? 1 : 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Transaction copyWith({
    String? id,
    double? amount,
    String? accountName,
    String? accountNumber,
    String? date,
    String? time,
    String? type,
    String? category,
    String? title,
    String? notes,
    String? link,
    String? error,
    double? vat,
    double? serviceFee,
    String? tags,
    String? transactionId,
    double? confidence,
    String? emailId,
    String? rawEmail,
    bool? isConfirmed,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      link: link ?? this.link,
      error: error ?? this.error,
      vat: vat ?? this.vat,
      serviceFee: serviceFee ?? this.serviceFee,
      tags: tags ?? this.tags,
      transactionId: transactionId ?? this.transactionId,
      confidence: confidence ?? this.confidence,
      emailId: emailId ?? this.emailId,
      rawEmail: rawEmail ?? this.rawEmail,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}
