import 'package:flutter/material.dart';
import 'package:reelify/core/theme/app_theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore', style: TextStyle(color: AppColors.textPrimary))),
      body: const Center(
        child: Text('Explore features coming soon!', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
