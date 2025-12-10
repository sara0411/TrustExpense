import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/monthly_summary_model.dart';
import '../models/receipt_model.dart';
import '../services/supabase_service.dart';
import '../../core/constants/app_constants.dart';

/// Repository for calculating and managing monthly summaries
class SummaryRepository {
  final SupabaseService _supabaseService;

  SummaryRepository(this._supabaseService);

  /// Get month string from DateTime (format: YYYY-MM)
  String _getMonthString(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  /// Get start and end dates for a month
  (DateTime start, DateTime end) _getMonthRange(String month) {
    final date = DateTime.parse('$month-01');
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    return (start, end);
  }

  /// Calculate monthly summary from receipts
  Future<MonthlySummary> getMonthlySummary(String month) async {
    try {
      final (startDate, endDate) = _getMonthRange(month);

      // Get all receipts for the month
      final receipts = await _supabaseService.getReceipts(
        limit: 1000, // Get all receipts for the month
        startDate: startDate,
        endDate: endDate,
      );

      if (receipts.isEmpty) {
        return MonthlySummary.empty(month);
      }

      // Calculate totals
      double totalAmount = 0.0;
      final Map<String, double> categoryBreakdown = {};

      // Initialize all categories with 0
      for (final category in AppConstants.expenseCategories) {
        categoryBreakdown[category] = 0.0;
      }

      // Sum up amounts by category
      for (final receipt in receipts) {
        totalAmount += receipt.amount;
        categoryBreakdown[receipt.category] = 
            (categoryBreakdown[receipt.category] ?? 0.0) + receipt.amount;
      }

      // Remove categories with 0 spending
      categoryBreakdown.removeWhere((key, value) => value == 0.0);

      return MonthlySummary(
        month: month,
        totalAmount: totalAmount,
        receiptCount: receipts.length,
        categoryBreakdown: categoryBreakdown,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error calculating monthly summary: $e');
      rethrow;
    }
  }

  /// Get summary for current month
  Future<MonthlySummary> getCurrentMonthSummary() async {
    final currentMonth = _getMonthString(DateTime.now());
    return getMonthlySummary(currentMonth);
  }

  /// Get category breakdown for a specific month
  Future<Map<String, double>> getCategoryBreakdown(String month) async {
    final summary = await getMonthlySummary(month);
    return summary.categoryBreakdown;
  }

  /// Get daily spending for a month (for bar chart)
  Future<Map<int, double>> getDailySpending(String month) async {
    try {
      final (startDate, endDate) = _getMonthRange(month);

      final receipts = await _supabaseService.getReceipts(
        limit: 1000,
        startDate: startDate,
        endDate: endDate,
      );

      final Map<int, double> dailySpending = {};

      for (final receipt in receipts) {
        final day = receipt.date.day;
        dailySpending[day] = (dailySpending[day] ?? 0.0) + receipt.amount;
      }

      return dailySpending;
    } catch (e) {
      debugPrint('Error calculating daily spending: $e');
      rethrow;
    }
  }

  /// Get monthly trend (last N months)
  Future<List<MonthlySummary>> getMonthlyTrend(int months) async {
    final summaries = <MonthlySummary>[];
    final now = DateTime.now();

    for (int i = 0; i < months; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthString = _getMonthString(date);
      
      try {
        final summary = await getMonthlySummary(monthString);
        summaries.add(summary);
      } catch (e) {
        debugPrint('Error getting summary for $monthString: $e');
        // Add empty summary if error
        summaries.add(MonthlySummary.empty(monthString));
      }
    }

    return summaries;
  }

  /// Get top spending categories for a month
  Future<List<MapEntry<String, double>>> getTopCategories(
    String month, {
    int limit = 5,
  }) async {
    final summary = await getMonthlySummary(month);
    
    final entries = summary.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.take(limit).toList();
  }

  /// Get receipts for a specific category in a month
  Future<List<Receipt>> getReceiptsByCategory(
    String month,
    String category,
  ) async {
    final (startDate, endDate) = _getMonthRange(month);

    return await _supabaseService.getReceipts(
      limit: 1000,
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get previous month string
  String getPreviousMonth(String month) {
    final date = DateTime.parse('$month-01');
    final previous = DateTime(date.year, date.month - 1, 1);
    return _getMonthString(previous);
  }

  /// Get next month string
  String getNextMonth(String month) {
    final date = DateTime.parse('$month-01');
    final next = DateTime(date.year, date.month + 1, 1);
    return _getMonthString(next);
  }

  /// Check if month is current month
  bool isCurrentMonth(String month) {
    return month == _getMonthString(DateTime.now());
  }

  /// Check if month is in the future
  bool isFutureMonth(String month) {
    final monthDate = DateTime.parse('$month-01');
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    return monthDate.isAfter(currentMonth);
  }
}
