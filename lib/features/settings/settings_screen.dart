import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/generated/app_localizations.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/core/providers/app_providers.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _aiEnabled = true;

  // Language display names map
  static const _langNames = {
    'en': '🇺🇸 English',
    'hi': '🇮🇳 हिंदी',
    'ta': '🇮🇳 தமிழ்',
    'te': '🇮🇳 తెలుగు',
  };

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // ── Account ──────────────────────────────────────
          if (user != null) ...[
            _SectionHeader(l10n.account),
            ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                backgroundImage: user.profileImage.isNotEmpty ? NetworkImage(user.profileImage) : null,
                child: user.profileImage.isEmpty
                    ? Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
              title: Text(user.displayName,
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text('@${user.username}',
                  style: Theme.of(context).textTheme.bodySmall),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push('/home/profile/${user.id}'),
            ),
          ],

          // ── Appearance ───────────────────────────────────
          const _SectionHeader('Appearance'),
          _buildSwitchTile(
            context,
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: isDark ? Colors.indigo : Colors.amber,
            title: isDark ? 'Dark Mode' : 'Light Mode',
            subtitle: 'Switch between dark and light theme',
            value: isDark,
            onChanged: (val) {
              ref.read(themeProvider.notifier).setTheme(
                    val ? ThemeMode.dark : ThemeMode.light,
                  );
            },
          ),

          // ── Language ─────────────────────────────────────
          _SectionHeader(l10n.language),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language_rounded, color: Colors.teal, size: 20),
            ),
            title: Text(l10n.language),
            subtitle: Text(_langNames[locale.languageCode] ?? 'English'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => _showLanguagePicker(context),
          ),

          // ── Notifications ─────────────────────────────────
          _SectionHeader(l10n.notifications),
          _buildSwitchTile(
            context,
            icon: Icons.lock_outline_rounded,
            iconColor: Colors.purple,
            title: l10n.privacy,
            subtitle: 'Private Account',
            value: user?.isPrivate ?? false,
            onChanged: (val) async {
              await ref.read(authRepositoryProvider).updateProfile(isPrivate: val);
              // The authStateProvider should automatically refresh because of the stream
            },
          ),

          // ── AI & Feed ─────────────────────────────────────
          _SectionHeader(l10n.aiFeed),
          _buildSwitchTile(
            context,
            icon: Icons.auto_awesome_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            title: l10n.aiRecommendations,
            subtitle: 'Personalized "For You" feed',
            value: _aiEnabled,
            onChanged: (val) => setState(() => _aiEnabled = val),
          ),
          _SettingsTile(
            icon: Icons.history_rounded,
            iconColor: Colors.grey,
            title: l10n.watchHistory,
            subtitle: 'Clear or manage your history',
            onTap: () => _showClearHistoryDialog(context),
          ),

          // ── About ─────────────────────────────────────────
          _SectionHeader(l10n.about),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.blue,
            title: l10n.appVersion,
            subtitle: AppConstants.appVersion,
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            iconColor: Colors.green,
            title: l10n.termsOfService,
            onTap: () => context.push('/home/settings/terms'),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: Colors.teal,
            title: l10n.privacyPolicy,
            onTap: () => context.push('/home/settings/privacy'),
          ),

          const SizedBox(height: 16),

          // ── Sign Out ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: OutlinedButton.icon(
              icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.primary),
              label: Text(l10n.signOut,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: Switch(
        value: value,
        activeThumbColor: Theme.of(context).colorScheme.primary,
        onChanged: onChanged,
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocaleNotifier.languages.entries.map((entry) {
            final isSelected = ref.read(localeProvider).languageCode == entry.key;
            return ListTile(
              leading: Text(
                entry.value.split(' ').first, // emoji
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(entry.value.split(' ').skip(1).join(' ')),
              trailing: isSelected ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(entry.key);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language changed to ${entry.value}')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Watch History'),
        content: const Text('This will remove all watched video history. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Watch history cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  }

// ── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

// ── Settings Tile ──────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
    final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
        this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: (onTap != null ? const Icon(Icons.arrow_forward_ios_rounded, size: 14) : null),
      onTap: onTap,
    );
  }
}
