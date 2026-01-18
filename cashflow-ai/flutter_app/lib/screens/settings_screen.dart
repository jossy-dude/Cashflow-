import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/sync_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import '../utils/haptic_feedback.dart';
import 'parser_intelligence_screen.dart';
import 'email_config_screen.dart';
import 'appearance_settings_screen.dart';
import 'export_screen.dart';
import 'storage_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Integration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEmailConnectionSection(context),
          const SizedBox(height: 16),
          _buildParserIntelligenceSection(context),
          const SizedBox(height: 24),
          _buildAppearanceSection(context),
          const SizedBox(height: 24),
          _buildDataManagementSection(context),
          const SizedBox(height: 24),
          _buildSyncSettingsSection(context),
        ],
      ),
    );
  }

  Widget _buildEmailConnectionSection(BuildContext context) {
    return AnimatedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Configuration',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure IMAP settings for email parsing',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme.onSurface
                      .withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmailConfigScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Configure Email Settings'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return AnimatedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize theme, colors, and visual settings',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme.onSurface
                      .withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppearanceSettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.palette),
              label: const Text('Appearance Settings'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection(BuildContext context) {
    return AnimatedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.file_download, color: AppTheme.primaryColor),
            title: const Text('Export Data'),
            subtitle: const Text('Export transactions to CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.storage, color: AppTheme.primaryColor),
            title: const Text('Storage Management'),
            subtitle: const Text('View and manage exported files'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StorageManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParserIntelligenceSection(BuildContext context) {
    return AnimatedCard(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.red.shade500],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.mail, color: Colors.white),
        ),
        title: const Text(
          'Parser Intelligence',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('View parsing engine details'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          HapticFeedbackUtil.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ParserIntelligenceScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Engine',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Personalize your financial dashboard',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildThemeOption(
                      context,
                      'Midnight',
                      themeProvider.selectedTheme == 'midnight',
                      [const Color(0xFF101922), AppTheme.primaryColor, const Color(0xFF1C2936)],
                      () => themeProvider.setSelectedTheme('midnight'),
                    ),
                    _buildThemeOption(
                      context,
                      'Solar',
                      themeProvider.selectedTheme == 'solar',
                      [const Color(0xFF1A120B), Colors.orange, const Color(0xFF2D1E12)],
                      () => themeProvider.setSelectedTheme('solar'),
                    ),
                    _buildThemeOption(
                      context,
                      'Leaf',
                      themeProvider.selectedTheme == 'leaf',
                      [const Color(0xFF0A1810), Colors.green, const Color(0xFF12261A)],
                      () => themeProvider.setSelectedTheme('leaf'),
                    ),
                    _buildThemeOption(
                      context,
                      'Dynamic',
                      themeProvider.selectedTheme == 'dynamic',
                      [Colors.purple, Colors.blue, Colors.teal],
                      () => themeProvider.setSelectedTheme('dynamic'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String name,
    bool isSelected,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Color(0xFF11221C),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: colors.map((color) {
                return Expanded(
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSettingsSection(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sync Frequency',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Every ${syncProvider.syncFrequency} minutes'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Every ${syncProvider.syncFrequency} mins',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: syncProvider.syncFrequency.toDouble(),
                  min: 15,
                  max: 1440,
                  divisions: 5,
                  label: '${syncProvider.syncFrequency} minutes',
                  onChanged: (value) {
                    syncProvider.setSyncFrequency(value.toInt());
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('15m', style: Theme.of(context).textTheme.bodySmall),
                    Text('1h', style: Theme.of(context).textTheme.bodySmall),
                    Text('6h', style: Theme.of(context).textTheme.bodySmall),
                    Text('12h', style: Theme.of(context).textTheme.bodySmall),
                    Text('Daily', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
