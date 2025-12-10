import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

/// Bar chart widget showing daily spending
class SpendingBarChart extends StatelessWidget {
  final Map<int, double> dailySpending;
  final String month;

  const SpendingBarChart({
    super.key,
    required this.dailySpending,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    if (dailySpending.isEmpty) {
      return _buildEmptyState();
    }

    final maxY = _getMaxY();

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.black87,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final day = group.x.toInt() + 1;
                  final amount = rod.toY;
                  return BarTooltipItem(
                    'Day $day\n\$${amount.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final day = value.toInt() + 1;
                    // Show every 5th day to avoid crowding
                    if (day % 5 == 0 || day == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '$day',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
                left: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            barGroups: _getBarGroups(),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    final sortedDays = dailySpending.keys.toList();
    sortedDays.sort();
    
    return sortedDays.map((day) {
      final amount = dailySpending[day]!;
      return BarChartGroupData(
        x: day - 1, // 0-indexed for chart
        barRods: [
          BarChartRodData(
            toY: amount,
            color: AppColors.primary,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    if (dailySpending.isEmpty) return 100;
    
    final maxValue = dailySpending.values.reduce((a, b) => a > b ? a : b);
    // Round up to nearest 10 or 100 for nice chart scaling
    if (maxValue < 100) {
      return ((maxValue / 10).ceil() * 10).toDouble();
    } else {
      return ((maxValue / 100).ceil() * 100).toDouble();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No daily spending data',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
