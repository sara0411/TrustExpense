import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_design_system.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/monthly_summary_model.dart';
import '../../providers/summary_provider.dart';
import '../../widgets/charts/category_pie_chart.dart';
import '../../widgets/charts/spending_bar_chart.dart';

/// Summary screen - Clean, professional design
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.background,
      body: Consumer<SummaryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          if (!provider.hasData) {
            return _buildEmptyState();
          }

          return _buildSummaryContent(provider);
        },
      ),
    );
  }

  Widget _buildSummaryContent(SummaryProvider provider) {
    final summary = provider.currentSummary!;

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppDesignSystem.primary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Clean app bar
          _buildAppBar(provider),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppDesignSystem.space20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Total card - clean white
                _buildTotalCard(summary),

                const SizedBox(height: AppDesignSystem.space20),

                // Stats row
                _buildStatsRow(summary),

                const SizedBox(height: AppDesignSystem.space32),

                // Category breakdown
                Text(
                  'Category Breakdown',
                  style: AppDesignSystem.headlineMedium,
                ),
                const SizedBox(height: AppDesignSystem.space16),
                _buildCategoryChart(summary, provider.dailySpending ?? {}),

                const SizedBox(height: AppDesignSystem.space32),

                // Daily spending
                Text(
                  'Daily Spending',
                  style: AppDesignSystem.headlineMedium,
                ),
                const SizedBox(height: AppDesignSystem.space16),
                _buildDailyChart(provider.dailySpending ?? {}, provider.selectedMonth),

                const SizedBox(height: AppDesignSystem.space32),

                // Category list
                Text(
                  'Details',
                  style: AppDesignSystem.headlineMedium,
                ),
                const SizedBox(height: AppDesignSystem.space16),
                _buildCategoryList(summary),

                const SizedBox(height: AppDesignSystem.space48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(SummaryProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 16), // Increased top padding
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Month selector - full width, centered
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.divider,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: provider.goToPreviousMonth,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        provider.formattedMonth,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: provider.isFutureMonth ? null : provider.goToNextMonth,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: provider.isFutureMonth
                                ? AppColors.textDisabled
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(MonthlySummary summary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkerGreen, // Dark green like home screen
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Enhanced layered shadows
          BoxShadow(
            color: AppColors.darkerGreen.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: AppColors.darkerGreen.withValues(alpha: 0.2),
            blurRadius: 60,
            offset: const Offset(0, 20),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spent',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Large white amount
          Text(
            summary.formattedTotal,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2.0,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                '${summary.receiptCount} receipts',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.trending_up,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                '${summary.formattedAverage} avg',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(MonthlySummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Top Category',
            summary.topCategory ?? 'N/A',
            Icons.star_outline,
          ),
        ),
        const SizedBox(width: AppDesignSystem.space12),
        Expanded(
          child: _buildStatCard(
            'Categories',
            '${summary.categoryBreakdown.length}',
            Icons.category_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
        boxShadow: AppDesignSystem.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppDesignSystem.primary,
          ),
          const SizedBox(height: AppDesignSystem.space12),
          Text(
            label,
            style: AppDesignSystem.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppDesignSystem.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(
    MonthlySummary summary,
    Map<int, double> dailySpending,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive padding based on screen width
        final screenWidth = MediaQuery.of(context).size.width;
        final padding = screenWidth < 360 ? 12.0 : 16.0;
        
        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CategoryPieChart(
            categoryBreakdown: summary.categoryBreakdown,
            totalAmount: summary.totalAmount,
          ),
        );
      },
    );
  }

  Widget _buildDailyChart(Map<int, double> dailySpending, String month) {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.space20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
        boxShadow: AppDesignSystem.shadowSmall,
      ),
      child: SpendingBarChart(
        dailySpending: dailySpending,
        month: month,
      ),
    );
  }

  Widget _buildCategoryList(MonthlySummary summary) {
    final entries = summary.categoryBreakdown.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.map((entry) {
        final percentage = summary.getCategoryPercentage(entry.key);
        final color = AppColors.getCategoryColor(entry.key);

        return Container(
          margin: const EdgeInsets.only(bottom: 16), // Increased spacing
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.03),
              width: 1,
            ),
            boxShadow: [
              // Enhanced layered shadows
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 32,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            children: [
              // Neutral gray icon background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6), // Light gray
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  AppConstants.getCategoryIcon(entry.key),
                  color: color, // Medium gray icon
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Larger, bolder amount
              Text(
                '\$${entry.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(SummaryProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppDesignSystem.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading summary',
            style: AppDesignSystem.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? 'Unknown error',
            style: AppDesignSystem.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: provider.refresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppDesignSystem.textTertiary,
          ),
          const SizedBox(height: 24),
          Text(
            'No receipts this month',
            style: AppDesignSystem.headlineMedium.copyWith(
              color: AppDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start scanning receipts to see your summary',
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
