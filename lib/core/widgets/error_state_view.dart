import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'app_button.dart';

class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.riskHighBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.riskHigh),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 160,
              child: AppButton(
                text: 'Retry',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
