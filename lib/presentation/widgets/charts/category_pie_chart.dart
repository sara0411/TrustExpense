import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

/// Pie chart widget showing category breakdown
class CategoryPieChart extends StatefulWidget {
  final Map<String, double> categoryBreakdown;
  final double totalAmount;

  const CategoryPieChart({
    super.key,
    required this.categoryBreakdown,
    required this.totalAmount,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryBreakdown.isEmpty || widget.totalAmount == 0) {
      return _buildEmptyState();
    }

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final centerSpaceRadius = isSmallScreen ? 30.0 : 35.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Make chart more compact - use constrained height
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: isSmallScreen ? 180 : 200,
          ),
          child: Row(
            children: [
              // Pie Chart - takes less space
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex =
                              pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: centerSpaceRadius,
                    sections: _getSections(),
                  ),
                ),
              ),

              // Legend - takes more space for readability
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                flex: 2,
                child: _buildLegend(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _getSections() {
    final entries = widget.categoryBreakdown.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return List.generate(entries.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched 
          ? (isSmallScreen ? 12.0 : 14.0) 
          : (isSmallScreen ? 10.0 : 11.0);
      final radius = isTouched 
          ? (isSmallScreen ? 50.0 : 55.0) 
          : (isSmallScreen ? 42.0 : 47.0);

      final entry = entries[i];
      final percentage = (entry.value / widget.totalAmount) * 100;

      return PieChartSectionData(
        color: AppColors.getCategoryColor(entry.key),
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black26, blurRadius: 2),
          ],
        ),
      );
    });
  }

  Widget _buildLegend() {
    final entries = widget.categoryBreakdown.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.map((entry) {
        final percentage = (entry.value / widget.totalAmount) * 100;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.getCategoryColor(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Category name and percentage
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No spending data',
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
