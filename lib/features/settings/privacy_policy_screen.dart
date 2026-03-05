import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/generated/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.privacyPolicy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Last updated: March 2024', style: theme.textTheme.bodySmall),
            const SizedBox(height: 24),
            _buildSection(theme, '1. Information We Collect', 
              'We collect information you provide directly to us, such as when you create an account, profile information, and content you post. We also collect usage data like watch time, likes, and interactions.'),
            _buildSection(theme, '2. How We Use Information', 
              'We use the information to provide, maintain, and improve the App, personalize your feed using AI, and communicate with you.'),
            _buildSection(theme, '3. Data Sharing', 
              'We do not sell your personal data. We may share information with service providers who perform services on our behalf or for legal reasons.'),
            _buildSection(theme, '4. Your Choices', 
              'You can manage your account settings, including privacy toggles, and delete your account at any time.'),
            _buildSection(theme, '5. Security', 
              'We take reasonable measures to help protect your information from loss, theft, misuse, and unauthorized access.'),
            const SizedBox(height: 40),
            Text('© 2024 RAY App. All rights reserved.', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
