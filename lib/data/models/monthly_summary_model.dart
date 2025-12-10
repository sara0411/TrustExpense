import 'package:intl/intl.dart';

/// Model for monthly expense summary
class MonthlySummary {
  final String month; // Format: YYYY-MM
  final double totalAmount;
  final int receiptCount;
  final Map<String, double> categoryBreakdown;
  final DateTime generatedAt;

  const MonthlySummary({
    required this.month,
    required this.totalAmount,
    required this.receiptCount,
    required this.categoryBreakdown,
    required this.generatedAt,
  });

  /// Get formatted month string (e.g., "November 2025")
  String get formattedMonth {
    final date = DateTime.parse('$month-01');
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Get short formatted month (e.g., "Nov 2025")
  String get shortFormattedMonth {
    final date = DateTime.parse('$month-01');
    return DateFormat('MMM yyyy').format(date);
  }

  /// Get average amount per receipt
  double get averageAmount {
    if (receiptCount == 0) return 0.0;
    return totalAmount / receiptCount;
  }

  /// Get formatted total amount
  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';

  /// Get formatted average
  String get formattedAverage => '\$${averageAmount.toStringAsFixed(2)}';

  /// Get top category (highest spending)
  String? get topCategory {
    if (categoryBreakdown.isEmpty) return null;
    
    String topCat = categoryBreakdown.keys.first;
    double maxAmount = categoryBreakdown.values.first;
    
    for (final entry in categoryBreakdown.entries) {
      if (entry.value > maxAmount) {
        maxAmount = entry.value;
        topCat = entry.key;
      }
    }
    
    return topCat;
  }

  /// Get percentage for a category
  double getCategoryPercentage(String category) {
    if (totalAmount == 0) return 0.0;
    final amount = categoryBreakdown[category] ?? 0.0;
    return (amount / totalAmount) * 100;
  }

  /// Get formatted percentage for a category
  String getFormattedPercentage(String category) {
    return '${getCategoryPercentage(category).toStringAsFixed(1)}%';
  }

  /// Create empty summary for a month
  factory MonthlySummary.empty(String month) {
    return MonthlySummary(
      month: month,
      totalAmount: 0.0,
      receiptCount: 0,
      categoryBreakdown: {},
      generatedAt: DateTime.now(),
    );
  }

  /// Create from JSON (for Supabase storage)
  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      month: json['month'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      receiptCount: json['receipt_count'] as int,
      categoryBreakdown: Map<String, double>.from(
        (json['category_breakdown'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  /// Convert to JSON (for Supabase storage)
  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'total_amount': totalAmount,
      'receipt_count': receiptCount,
      'category_breakdown': categoryBreakdown,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  /// Copy with method
  MonthlySummary copyWith({
    String? month,
    double? totalAmount,
    int? receiptCount,
    Map<String, double>? categoryBreakdown,
    DateTime? generatedAt,
  }) {
    return MonthlySummary(
      month: month ?? this.month,
      totalAmount: totalAmount ?? this.totalAmount,
      receiptCount: receiptCount ?? this.receiptCount,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  String toString() {
    return 'MonthlySummary(month: $month, total: $formattedTotal, count: $receiptCount, categories: ${categoryBreakdown.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MonthlySummary && other.month == month;
  }

  @override
  int get hashCode => month.hashCode;
}
