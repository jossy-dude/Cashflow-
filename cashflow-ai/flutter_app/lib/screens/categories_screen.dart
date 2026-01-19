import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import '../utils/haptic_feedback.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories & Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddCategoryDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryCard(
            context,
            'Food',
            Icons.restaurant,
            Colors.orange,
            450.0,
            600.0,
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            'Transport',
            Icons.directions_car,
            Colors.blue,
            120.0,
            200.0,
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            'Rent',
            Icons.home,
            Colors.purple,
            600.0,
            600.0,
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            'Shopping',
            Icons.shopping_bag,
            Colors.pink,
            200.0,
            500.0,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
    double spent,
    double limit,
  ) {
    final percentage = (spent / limit).clamp(0.0, 1.0);

    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      onTap: () {
        HapticFeedbackUtil.lightImpact();
        _showEditCategoryDialog(context, name, limit, icon, color);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'ETB $spent / ETB $limit',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme.onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  HapticFeedbackUtil.lightImpact();
                  _showEditCategoryDialog(context, name, limit, icon, color);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percentage * 100).toInt()}% used',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'ETB ${(limit - spent).toStringAsFixed(2)} remaining',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    String name,
    double budget,
    IconData icon,
    Color color,
  ) {
    final budgetController = TextEditingController(text: budget.toStringAsFixed(2));
    HapticFeedbackUtil.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $name'),
        content: TextField(
          controller: budgetController,
          decoration: const InputDecoration(
            labelText: 'Monthly Budget (ETB)',
            prefixIcon: Icon(Icons.attach_money),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedbackUtil.mediumImpact();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Budget updated to ETB ${budgetController.text}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    String selectedIcon = 'category';
    Color selectedColor = AppTheme.primaryColor;

    HapticFeedbackUtil.lightImpact();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Budget (ETB)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Icon selection
                Text(
                  'Select Icon',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'restaurant',
                    'directions_car',
                    'home',
                    'shopping_bag',
                    'category',
                    'fitness_center',
                    'local_movies',
                    'school',
                  ].map((icon) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedIcon = icon);
                        HapticFeedbackUtil.selectionClick();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedIcon == icon
                              ? selectedColor.withOpacity(0.2)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedIcon == icon
                                ? selectedColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getIconData(icon),
                          color: selectedIcon == icon ? selectedColor : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Color selection
                Text(
                  'Select Color',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    AppTheme.primaryColor,
                    Colors.orange,
                    Colors.blue,
                    Colors.purple,
                    Colors.pink,
                    Colors.teal,
                    Colors.red,
                    Colors.green,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedColor = color);
                        HapticFeedbackUtil.selectionClick();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  HapticFeedbackUtil.mediumImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category "${nameController.text}" added'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_movies':
        return Icons.local_movies;
      case 'school':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}
