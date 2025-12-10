import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/monthly_summary_model.dart';
import '../../data/repositories/summary_repository.dart';

/// Provider for managing summary state
class SummaryProvider with ChangeNotifier {
  final SummaryRepository _repository;

  SummaryProvider(this._repository) {
    // Initialize with current month
    _selectedMonth = _getCurrentMonthString();
    loadSummary();
  }

  // State
  MonthlySummary? _currentSummary;
  String _selectedMonth = '';
  bool _isLoading = false;
  String? _error;
  Map<int, double>? _dailySpending;

  // Getters
  MonthlySummary? get currentSummary => _currentSummary;
  String get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<int, double>? get dailySpending => _dailySpending;

  bool get hasData => _currentSummary != null && _currentSummary!.receiptCount > 0;
  bool get isCurrentMonth => _repository.isCurrentMonth(_selectedMonth);
  bool get isFutureMonth => _repository.isFutureMonth(_selectedMonth);

  /// Get current month string (YYYY-MM)
  String _getCurrentMonthString() {
    return DateFormat('yyyy-MM').format(DateTime.now());
  }

  /// Load summary for selected month
  Future<void> loadSummary() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('📊 Loading summary for month: $_selectedMonth');

      // Load summary and daily spending in parallel
      final results = await Future.wait([
        _repository.getMonthlySummary(_selectedMonth),
        _repository.getDailySpending(_selectedMonth),
      ]);

      _currentSummary = results[0] as MonthlySummary;
      _dailySpending = results[1] as Map<int, double>;

      debugPrint('✅ Summary loaded: ${_currentSummary?.receiptCount} receipts, total: ${_currentSummary?.formattedTotal}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading summary: $e');
      _error = 'Failed to load summary: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Navigate to previous month
  Future<void> goToPreviousMonth() async {
    _selectedMonth = _repository.getPreviousMonth(_selectedMonth);
    await loadSummary();
  }

  /// Navigate to next month
  Future<void> goToNextMonth() async {
    // Don't allow navigating to future months
    if (_repository.isFutureMonth(_repository.getNextMonth(_selectedMonth))) {
      return;
    }
    
    _selectedMonth = _repository.getNextMonth(_selectedMonth);
    await loadSummary();
  }

  /// Go to current month
  Future<void> goToCurrentMonth() async {
    _selectedMonth = _getCurrentMonthString();
    await loadSummary();
  }

  /// Select specific month
  Future<void> selectMonth(String month) async {
    if (_repository.isFutureMonth(month)) {
      return; // Don't allow future months
    }
    
    _selectedMonth = month;
    await loadSummary();
  }

  /// Refresh current summary
  Future<void> refresh() async {
    await loadSummary();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get formatted month display
  String get formattedMonth {
    if (_currentSummary != null) {
      return _currentSummary!.formattedMonth;
    }
    final date = DateTime.parse('$_selectedMonth-01');
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Get short formatted month
  String get shortFormattedMonth {
    if (_currentSummary != null) {
      return _currentSummary!.shortFormattedMonth;
    }
    final date = DateTime.parse('$_selectedMonth-01');
    return DateFormat('MMM yyyy').format(date);
  }
}
