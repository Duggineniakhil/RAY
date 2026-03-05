import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/core/theme/app_theme.dart';
import 'package:reelify/generated/app_localizations.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/widgets/gradient_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (mounted) {
      final state = ref.read(authNotifierProvider);
      state.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        },
        data: (user) {
          if (user != null) context.go('/home');
        },
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (mounted) {
      final state = ref.read(authNotifierProvider);
      state.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        },
        data: (user) {
          if (user != null) context.go('/home');
        },
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 48),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 32),

                  Text(
                    'Welcome back 👋',
                    style: Theme.of(context).textTheme.displaySmall,
                  ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2),

                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue watching',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate(delay: 200.ms).fadeIn(),

                  const SizedBox(height: 40),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.email,
                      prefixIcon: Icon(Icons.email_outlined,
                          color: theme.hintColor),
                    ),
                    validator: (v) =>
                        v == null || !v.contains('@') ? 'Enter valid email' : null,
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.password,
                      prefixIcon: Icon(Icons.lock_outline,
                          color: theme.hintColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: theme.hintColor,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.length < 6 ? 'Min 6 characters' : null,
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 28),

                  // Sign In Button
                  GradientButton(
                    label: l10n.signIn,
                    onPressed: _isLoading ? null : _signIn,
                    isLoading: _isLoading,
                  ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.dividerColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or',
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                      Expanded(child: Divider(color: theme.dividerColor)),
                    ],
                  ).animate(delay: 600.ms).fadeIn(),

                  const SizedBox(height: 16),

                  // Google Sign In
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: Icon(Icons.g_mobiledata_rounded,
                        size: 28, color: theme.colorScheme.onSurface),
                    label: Text(l10n.continueWithGoogle),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // Sign Up link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium),
                        GestureDetector(
                          onTap: () => context.push('/login/signup'),
                          child: Text(
                            l10n.signUp,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 800.ms).fadeIn(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
