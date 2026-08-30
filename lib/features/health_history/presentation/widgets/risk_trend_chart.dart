import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../assessment/data/models/assessment_model.dart';

class RiskTrendChart extends StatelessWidget {
  final List<AssessmentModel> assessments;

  const RiskTrendChart({super.key, required this.assessments});

  @override
  Widget build(BuildContext context) {
    if (assessments.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text('No historical data available to plot trends'),
        ),
      );
    }

    // Take up to 7 most recent records in chronological order
    final dataPoints = assessments.take(7).toList().reversed.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < dataPoints.length; i++) {
      // Plot glucose or BMI
      final val = dataPoints[i].glucose;
      spots.add(FlSpot(i.toDouble(), val));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 40,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.borderLight,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: 40,
                getTitlesWidget: (value, meta) => Text(
                  '',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < dataPoints.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '#',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 60,
          maxY: 240,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: AppColors.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
