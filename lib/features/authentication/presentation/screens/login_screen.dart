import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/disclaimer_card.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final success = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                // Logo & Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(Icons.favorite_rounded, size: 32, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Welcome back 👋',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sign in to access your health records & AI insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Error Banner
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.riskHighBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.riskHigh.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 20, color: AppColors.riskHigh),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: const TextStyle(fontSize: 13, color: AppColors.riskHigh),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Email
                AppTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: AppSpacing.md),

                // Password
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => Validators.validateRequired(v, 'Password'),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Login Button
                AppButton(
                  text: 'Sign In',
                  isLoading: authState.status == AuthStatus.loading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: AppSpacing.md),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const DisclaimerCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
