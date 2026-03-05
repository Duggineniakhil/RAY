import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/generated/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
        title: Text(l10n.termsOfService),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms of Service', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Last updated: March 2024', style: theme.textTheme.bodySmall),
            const SizedBox(height: 24),
            _buildSection(theme, '1. Acceptance of Terms', 
              'By accessing or using RAY (the "App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.'),
            _buildSection(theme, '2. User Content', 
              'You are solely responsible for the content you post on the App. You grant RAY a non-exclusive, royalty-free, worldwide license to use, store, and display your content.'),
            _buildSection(theme, '3. Prohibited Conduct', 
              'You agree not to post content that is illegal, offensive, or violates the rights of others. We reserve the right to remove any content at our discretion.'),
            _buildSection(theme, '4. AI Recommendations', 
              'RAY uses AI algorithms to personalize your feed. You understand that the recommendations are automated and may not always meet your expectations.'),
            _buildSection(theme, '5. Termination', 
              'We reserve the right to suspend or terminate your account at any time for any reason, including violation of these terms.'),
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
