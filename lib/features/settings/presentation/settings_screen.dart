import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config.dart';
import '../../../core/providers/app_state_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/api/prediction_service.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _versionTapCount = 0;
  final TextEditingController _urlController = TextEditingController();
  bool _isTestingHealth = false;
  String? _healthResult;

  @override
  void initState() {
    super.initState();
    _urlController.text = ref.read(configProvider).baseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _onVersionTapped() {
    AppHaptics.selectionClick();
    _versionTapCount++;
    if (_versionTapCount >= 7) {
      ref.read(configProvider.notifier).unlockDevMode();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.devUnlockedToast ??
                'Developer mode unlocked!',
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      _versionTapCount = 0;
    }
  }

  Future<void> _testHealth() async {
    setState(() {
      _isTestingHealth = true;
      _healthResult = null;
    });

    final service = ref.read(predictionServiceProvider);
    try {
      final res = await service.checkHealth();
      setState(() {
        _isTestingHealth = false;
        _healthResult = 'Status: ${res['status']} (${res['model_version'] ?? 'N/A'})';
      });
    } catch (e) {
      setState(() {
        _isTestingHealth = false;
        _healthResult = 'Error: $e';
      });
    }
  }

  Future<void> _confirmClearHistory(AppLocalizations? l10n) async {
    AppHaptics.selectionClick();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.clearHistoryLabel ?? 'Clear Scan History'),
        content: Text(
          l10n?.clearHistorySub ??
              'Are you sure you want to delete all stored scans from this device?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusUnknown,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.delete ?? 'Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(historyListProvider.notifier).clearAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.clearHistorySuccess ?? 'History cleared successfully',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final config = ref.watch(configProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsTitle ?? 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section: General
          _buildSectionHeader('General', theme),
          Card(
            child: Column(
              children: [
                // Language Selection
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.primaryGreen),
                  title: Text(l10n?.languageLabel ?? 'Language'),
                  subtitle: Text(
                    currentLocale?.languageCode == 'bn'
                        ? 'বাংলা (Bangla)'
                        : currentLocale?.languageCode == 'en'
                            ? 'English'
                            : (l10n?.themeSystem ?? 'System Default'),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showLanguageDialog(context, l10n, currentLocale),
                ),
                const Divider(height: 1),
                // Theme Selection
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: AppColors.primaryGreen),
                  title: Text(l10n?.themeLabel ?? 'Theme'),
                  subtitle: Text(
                    currentThemeMode == ThemeMode.light
                        ? (l10n?.themeLight ?? 'Light Theme')
                        : currentThemeMode == ThemeMode.dark
                            ? (l10n?.themeDark ?? 'Dark Theme')
                            : (l10n?.themeSystem ?? 'System Default'),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showThemeDialog(context, l10n, currentThemeMode),
                ),
                const Divider(height: 1),
                // Data Saver Mode
                SwitchListTile(
                  secondary: const Icon(Icons.speed_rounded, color: AppColors.primaryGreen),
                  title: Text(l10n?.dataSaverLabel ?? 'Data Saver Mode'),
                  subtitle: Text(
                    l10n?.dataSaverSub ??
                        'Compress images to smaller file size for slow mobile data',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: config.dataSaver,
                  onChanged: (val) {
                    AppHaptics.selectionClick();
                    ref.read(configProvider.notifier).setDataSaver(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section: Data & Storage
          _buildSectionHeader('Data & Storage', theme),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined, color: AppColors.statusUnknown),
                  title: Text(l10n?.clearHistoryLabel ?? 'Clear Scan History'),
                  subtitle: Text(
                    l10n?.clearHistorySub ?? 'Remove all stored scans from this device',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _confirmClearHistory(l10n),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section: About & Privacy
          _buildSectionHeader('About', theme),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryGreen),
                  title: Text(l10n?.privacyLabel ?? 'Privacy Policy'),
                  subtitle: Text(
                    l10n?.privacyContent ??
                        'Photos are processed strictly for plant disease inference.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Divider(height: 1),
                // Version Tile (Tap 7 times to unlock developer toggle)
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryGreen),
                  title: Text(l10n?.aboutLabel ?? 'About CropDoc'),
                  subtitle: Text('${l10n?.versionLabel ?? 'Version'} ${AppConfig.appVersion}'),
                  trailing: config.isDevModeUnlocked
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentLime.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'DEV',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                  onTap: _onVersionTapped,
                ),
              ],
            ),
          ),

          // Hidden Developer Mode Section
          if (config.isDevModeUnlocked) ...[
            const SizedBox(height: 20),
            _buildSectionHeader('Developer Options', theme),
            Card(
              color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF3F2EB),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.developer_mode_rounded,
                            color: AppColors.primaryGreen, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.developerModeTitle ?? 'Developer Settings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Toggle Mock vs Real Backend
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n?.devToggleMock ?? 'Use Mock Prediction Service',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        config.useMock
                            ? 'Currently using Mock Service (realistic simulations)'
                            : 'Currently using Real Backend via Dio HTTP',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: config.useMock,
                      onChanged: (val) {
                        AppHaptics.selectionClick();
                        ref.read(configProvider.notifier).setUseMock(val);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Base URL Input
                    Text(
                      l10n?.devBaseUrlLabel ?? 'Backend Base URL',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            decoration: const InputDecoration(
                              hintText: 'https://api.cropdoc.app',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(80, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: () {
                            AppHaptics.selectionClick();
                            ref
                                .read(configProvider.notifier)
                                .setBaseUrl(_urlController.text.trim());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n?.devUrlSaved ?? 'Base URL updated',
                                ),
                              ),
                            );
                          },
                          child: Text(l10n?.devSaveUrl ?? 'Save'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Health Check Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                      onPressed: _isTestingHealth ? null : _testHealth,
                      icon: _isTestingHealth
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.health_and_safety_outlined, size: 18),
                      label: Text(l10n?.devTestHealth ?? 'Test Server Health'),
                    ),
                    if (_healthResult != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _healthResult!,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    AppLocalizations? l10n,
    Locale? currentLocale,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n?.languageLabel ?? 'Select Language'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(localeProvider.notifier).setLocale('bn');
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('বাংলা (Bangla) - ডিফল্ট'),
                if (currentLocale?.languageCode == 'bn')
                  const Icon(Icons.check, color: AppColors.primaryGreen),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(localeProvider.notifier).setLocale('en');
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('English'),
                if (currentLocale?.languageCode == 'en')
                  const Icon(Icons.check, color: AppColors.primaryGreen),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(localeProvider.notifier).setLocale('system');
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n?.themeSystem ?? 'System Default'),
                if (currentLocale == null)
                  const Icon(Icons.check, color: AppColors.primaryGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeMode currentMode,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n?.themeLabel ?? 'Select Theme'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n?.themeSystem ?? 'System Default'),
                if (currentMode == ThemeMode.system)
                  const Icon(Icons.check, color: AppColors.primaryGreen),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n?.themeLight ?? 'Light Theme'),
                if (currentMode == ThemeMode.light)
                  const Icon(Icons.check, color: AppColors.primaryGreen),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n?.themeDark ?? 'Dark Theme'),
                if (currentMode == ThemeMode.dark)
                  const Icon(Icons.check, color: AppColors.primaryGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
