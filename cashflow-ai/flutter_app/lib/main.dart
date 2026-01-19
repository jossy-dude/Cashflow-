import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/haptic_feedback.dart';
import 'screens/dashboard_screen.dart';
import 'screens/review_inbox_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/sync_provider.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'widgets/smooth_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize database
  await DatabaseService.instance.database;
  runApp(const CashFlowApp());
}

class CashFlowApp extends StatelessWidget {
  const CashFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
          child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'CashFlow AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            scrollBehavior: SmoothScrollBehavior(),
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ReviewInboxScreen(),
    const CategoriesScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load transactions on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.dashboard, 'Home'),
                  _buildNavItem(1, Icons.receipt_long, 'Transact'),
                  const SizedBox(width: 40), // Space for FAB
                  _buildNavItem(2, Icons.pie_chart, 'Stats'),
                  _buildNavItem(3, Icons.person, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedbackUtil.selectionClick();
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryColor
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Transform.scale(
        scale: 1.0,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedbackUtil.mediumImpact();
          _showManualEntryDialog();
        },
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            child: const Icon(Icons.add, color: Color(0xFF11221C), size: 32),
          ),
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ManualEntrySheet(),
    );
  }
}

class ManualEntrySheet extends StatefulWidget {
  const ManualEntrySheet({super.key});

  @override
  State<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<ManualEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedAccount = 'CBE';
  String _selectedCategory = 'Food';
  String _transactionType = 'debit';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manual Entry',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        // Amount
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount (ETB)',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Account
                        DropdownButtonFormField<String>(
                          initialValue: _selectedAccount,
                          decoration: const InputDecoration(
                            labelText: 'Account',
                            prefixIcon: Icon(Icons.account_balance),
                          ),
                          items: ['CBE', 'Telebirr', 'BOA', 'Dashen', 'Bunna']
                              .map((account) => DropdownMenuItem(
                                    value: account,
                                    child: Text(account),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAccount = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Transaction Type
                        DropdownButtonFormField<String>(
                          initialValue: _transactionType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            prefixIcon: Icon(Icons.swap_horiz),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'debit', child: Text('Debit')),
                            DropdownMenuItem(value: 'credit', child: Text('Credit')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _transactionType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Category
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: ['Food', 'Transport', 'Rent', 'Shopping', 'Other']
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Date
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Date'),
                          subtitle: Text(
                            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedDate = date;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                HapticFeedbackUtil.mediumImpact();
                final amount = double.parse(_amountController.text);
                final transaction = Transaction(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  amount: _transactionType == 'debit' ? -amount : amount,
                  accountName: _selectedAccount,
                  accountNumber: '',
                  date: _selectedDate.toString().split(' ')[0],
                  time: DateTime.now().toString().split(' ')[1].substring(0, 8),
                  type: _transactionType,
                  category: _selectedCategory.toLowerCase(),
                  title: '',
                  notes: 'Manual entry',
                  link: '',
                  error: '',
                  vat: 0.0,
                  serviceFee: 0.0,
                  tags: '',
                  transactionId: '',
                  confidence: 1.0,
                  emailId: '',
                  rawEmail: '',
                  isConfirmed: true,
                );
                
                final provider = Provider.of<TransactionProvider>(context, listen: false);
                await provider.addTransaction(transaction);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Transaction added'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Transaction',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
