import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';

/// Bar chart of study minutes per day for the last 7 days — gives the
/// Study Planner screen its "productivity statistics" requirement.
class ProductivityStatsChart extends StatelessWidget {
  final List<double> last7DaysMinutes; // index 0 = 6 days ago ... index 6 = today
  const ProductivityStatsChart({super.key, required this.last7DaysMinutes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxY = (last7DaysMinutes.isEmpty ? 60.0 : last7DaysMinutes.reduce((a, b) => a > b ? a : b)) + 20;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(labels[index], style: theme.textTheme.bodySmall),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(last7DaysMinutes.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: last7DaysMinutes[i],
                      color: theme.colorScheme.primary,
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
