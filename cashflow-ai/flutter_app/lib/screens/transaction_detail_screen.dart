import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import '../utils/haptic_feedback.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.amount > 0;
    final bankColor = AppTheme.getBankColor(transaction.accountName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              HapticFeedbackUtil.mediumImpact();
              // TODO: Edit transaction
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main amount card
            AnimatedCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ETB ${transaction.amount.abs().toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCredit ? AppTheme.primaryColor : null,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bankColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          transaction.accountName,
                          style: TextStyle(
                            color: bankColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      transaction.type.toUpperCase(),
                      style: TextStyle(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transaction info
            _buildInfoSection(
              context,
              'Transaction Information',
              [
                _buildInfoRow(context, 'Title', transaction.title.isNotEmpty ? transaction.title : 'N/A'),
                _buildInfoRow(context, 'Date', '${transaction.date} • ${transaction.time}'),
                _buildInfoRow(context, 'Account Number', transaction.accountNumber.isNotEmpty ? transaction.accountNumber : 'N/A'),
                if (transaction.transactionId.isNotEmpty)
                  _buildInfoRow(context, 'Transaction ID', transaction.transactionId),
              ],
            ),
            const SizedBox(height: 16),

            // Fees & VAT
            if (transaction.vat > 0 || transaction.serviceFee > 0)
              _buildInfoSection(
                context,
                'Fees & Charges',
                [
                  if (transaction.serviceFee > 0)
                    _buildInfoRow(context, 'Service Fee', 'ETB ${transaction.serviceFee.toStringAsFixed(2)}'),
                  if (transaction.vat > 0)
                    _buildInfoRow(context, 'VAT (15%)', 'ETB ${transaction.vat.toStringAsFixed(2)}'),
                  _buildInfoRow(
                    context,
                    'Total Charges',
                    'ETB ${(transaction.vat + transaction.serviceFee).toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Raw SMS
            _buildInfoSection(
              context,
              'Raw SMS',
              [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.notes,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return AnimatedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme.onSurface
                      .withOpacity(0.6),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}
