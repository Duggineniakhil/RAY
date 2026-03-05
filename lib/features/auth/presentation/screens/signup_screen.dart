import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/core/theme/app_theme.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/widgets/gradient_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await ref.read(authNotifierProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
        );
    if (mounted) {
      final state = ref.read(authNotifierProvider);
      state.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        ),
        data: (user) {
          if (user != null) context.go('/home');
        },
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Join Reelify 🎬',
                  style: Theme.of(context).textTheme.displaySmall,
                ).animate().fadeIn().slideX(begin: -0.2),
                const SizedBox(height: 8),
                Text(
                  'Create your account and discover amazing content',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: 36),

                // Username
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    prefixIcon:
                        Icon(Icons.person_outline, color: AppColors.textHint),
                  ),
                  validator: (v) => v == null || v.trim().length < 3
                      ? 'Min 3 characters'
                      : null,
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined,
                        color: AppColors.textHint),
                  ),
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter valid email' : null,
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Password (min 6 chars)',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.textHint),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 32),

                GradientButton(
                  label: 'Create Account',
                  onPressed: _isLoading ? null : _signUp,
                  isLoading: _isLoading,
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 24),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Sign In',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 600.ms).fadeIn(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
