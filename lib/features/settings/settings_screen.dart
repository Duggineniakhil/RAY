import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/core/theme/app_theme.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _aiEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile section
          if (user != null) ...[
            _SectionHeader('Account'),
            ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: user.profileImage.isNotEmpty
                    ? NetworkImage(user.profileImage)
                    : null,
                child: user.profileImage.isEmpty
                    ? const Icon(Icons.person_rounded,
                        color: Colors.white)
                    : null,
              ),
              title: Text(user.displayName,
                  style:
                      const TextStyle(color: AppColors.textPrimary)),
              subtitle: Text('@${user.username}',
                  style:
                      const TextStyle(color: AppColors.textSecondary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: AppColors.textSecondary),
              onTap: () => context.push('/home/profile/${user.id}'),
            ),
            const Divider(color: AppColors.divider),
          ],

          // Language
          _SectionHeader('Preferences'),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _showLanguageDialog(context),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage push notifications',
            onTap: () => _showComingSoonDialog(context, 'Notifications'),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy',
            subtitle: 'Account privacy settings',
            onTap: () => _showComingSoonDialog(context, 'Privacy Settings'),
          ),

          // AI
          _SectionHeader('AI & Feed'),
          _SettingsTile(
            icon: Icons.auto_awesome_rounded,
            title: 'AI Recommendations',
            subtitle: 'Personalized video feed',
            trailing: Switch(
              value: _aiEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() => _aiEnabled = val);
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.history_rounded,
            title: 'Watch History',
            subtitle: 'Clear or manage history',
            onTap: () => _showComingSoonDialog(context, 'Watch History'),
          ),

          // About
          _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: AppConstants.appVersion,
          ),
          _SettingsTile(
            icon: Icons.qr_code_rounded,
            title: 'My QR Code',
            subtitle: 'Share your profile via QR',
            onTap: () {
              if (user != null) {
                _showQrCode(context, user.id);
              }
            },
          ),
          _SettingsTile(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Scan QR Code',
            subtitle: 'Scan a creator\'s QR code',
            onTap: () => context.push('/home/qr-scanner'),
          ),

          const SizedBox(height: 16),

          // Sign out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
              label: const Text('Sign Out',
                  style: TextStyle(color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
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

  void _showComingSoonDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        content: const Text('This feature is currently under development.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Select Language',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'English',
            'हिंदी (Hindi)',
            'தமிழ் (Tamil)',
            'తెలుగు (Telugu)',
          ]
              .map((lang) => ListTile(
                    title: Text(lang,
                        style:
                            const TextStyle(color: AppColors.textPrimary)),
                    onTap: () => Navigator.pop(ctx),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showQrCode(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('My QR Code',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              height: 160,
              color: Colors.white,
              child: const Center(
                child: Icon(Icons.qr_code_2_rounded,
                    size: 140, color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'reelify://profile/$userId',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textHint,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(subtitle,
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.textSecondary)
              : null),
      onTap: onTap,
    );
  }
}
