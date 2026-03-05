import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _navigateAfterSplash();
  }

  void _navigateAfterSplash() {
    Future.delayed(AppConstants.splashDuration, () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Lottie Animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 72,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 1200.ms),

              const SizedBox(height: 28),

              // App Name
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: AppColors.primaryGradient,
                        ).createShader(
                          const Rect.fromLTWH(0, 0, 200, 50),
                        ),
                    ),
              ).animate(delay: 400.ms).fadeIn(duration: 600.ms).slideY(
                    begin: 0.3,
                    end: 0,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 8),

              Text(
                'AI-Powered Short Videos',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate(delay: 700.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                ),
              ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
