import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';

class HealthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Border? border;

  const HealthCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: border ?? Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}
