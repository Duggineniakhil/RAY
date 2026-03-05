import 'package:flutter/material.dart';
import 'package:reelify/core/theme/app_theme.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox', style: TextStyle(color: AppColors.textPrimary))),
      body: const Center(
        child: Text('Messaging features coming soon!', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
