import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class RiskGauge extends StatelessWidget {
  final double riskPercentage;
  final String riskCategory;
  final double size;

  const RiskGauge({
    super.key,
    required this.riskPercentage,
    required this.riskCategory,
    this.size = 180,
  });

  Color _getRiskColor() {
    if (riskPercentage < 35) return AppColors.riskLow;
    if (riskPercentage < 65) return AppColors.riskModerate;
    return AppColors.riskHigh;
  }

  Color _getRiskBgColor() {
    if (riskPercentage < 35) return AppColors.riskLowBg;
    if (riskPercentage < 65) return AppColors.riskModerateBg;
    return AppColors.riskHighBg;
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();
    final riskBg = _getRiskBgColor();

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  riskColor.withOpacity(0.15),
                ),
              ),
            ),
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: (riskPercentage.clamp(0, 100)) / 100,
                strokeWidth: 12,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(riskColor),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${riskPercentage.toInt()}%',
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w800,
                    color: riskColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(color: riskColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    riskCategory.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: riskColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
