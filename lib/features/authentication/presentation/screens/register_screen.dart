import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'Other';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final age = int.tryParse(_ageController.text.trim());
    final success = await ref.read(authProvider.notifier).register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      age: age,
      gender: _selectedGender,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join DiaSense Health',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Enter your details to begin proactive health tracking',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),

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

                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'John Doe',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (v) => Validators.validateRequired(v, 'Full name'),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Minimum 6 characters',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _ageController,
                        label: 'Age (Optional)',
                        hint: '35',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gender',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            height: AppSpacing.inputHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                isExpanded: true,
                                items: ['Male', 'Female', 'Other']
                                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedGender = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                AppButton(
                  text: 'Create Account',
                  isLoading: authState.status == AuthStatus.loading,
                  onPressed: _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
