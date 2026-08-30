import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'app_button.dart';

class EmptyStateView extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
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
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 200,
                child: AppButton(
                  text: actionText!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
