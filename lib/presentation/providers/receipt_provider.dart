import 'package:flutter/material.dart';
import '../../data/repositories/receipt_repository.dart';
import '../../data/models/receipt_model.dart';
import 'dart:io';

/// Provider for managing receipt state
class ReceiptProvider with ChangeNotifier {
  final ReceiptRepository _repository;

  ReceiptProvider(this._repository);

  // Delegate to repository
  List<Receipt> get receipts => _repository.receipts;
  bool get isLoading => _repository.isLoading;
  String? get error => _repository.error;
  int get totalCount => _repository.totalCount;
  bool get hasReceipts => _repository.hasReceipts;

  // Filter state
  String? _selectedCategory;
  DateTimeRange? _dateRange;
  String _searchQuery = '';

  String? get selectedCategory => _selectedCategory;
  DateTimeRange? get dateRange => _dateRange;
  String get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _selectedCategory != null ||
      _dateRange != null ||
      _searchQuery.isNotEmpty;

  Future<void> loadReceipts({
    int limit = 20,
    int offset = 0,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool append = false,
  }) async {
    await _repository.loadReceipts(
      limit: limit,
      offset: offset,
      category: category,
      startDate: startDate,
      endDate: endDate,
      append: append,
    );
    notifyListeners();
  }

  Future<Receipt> createReceipt({
    required double amount,
    required DateTime date,
    required String merchant,
    required String category,
    required double categoryConfidence,
    required bool manualOverride,
    required String ocrText,
    File? imageFile,
  }) async {
    final receipt = await _repository.createReceipt(
      amount: amount,
      date: date,
      merchant: merchant,
      category: category,
      categoryConfidence: categoryConfidence,
      manualOverride: manualOverride,
      ocrText: ocrText,
      imageFile: imageFile,
    );
    notifyListeners();
    return receipt;
  }

  Future<Receipt> updateReceipt(Receipt receipt) async {
    final updated = await _repository.updateReceipt(receipt);
    notifyListeners();
    return updated;
  }

  Future<void> deleteReceipt(String id) async {
    await _repository.deleteReceipt(id);
    notifyListeners();
  }

  double getTotalAmount() => _repository.getTotalAmount();
  
  List<Receipt> getReceiptsByCategory(String category) =>
      _repository.getReceiptsByCategory(category);

  void clearError() {
    _repository.clearError();
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadReceipts(
      category: _selectedCategory,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );
  }

  // Filter methods
  Future<void> filterByCategory(String? category) async {
    _selectedCategory = category;
    await loadReceipts(
      category: _selectedCategory,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );
  }

  Future<void> filterByDateRange(DateTimeRange? dateRange) async {
    _dateRange = dateRange;
    await loadReceipts(
      category: _selectedCategory,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );
  }

  void searchByMerchant(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> clearFilters() async {
    _selectedCategory = null;
    _dateRange = null;
    _searchQuery = '';
    await loadReceipts();
  }

  // Get filtered receipts (client-side search)
  List<Receipt> get filteredReceipts {
    if (_searchQuery.isEmpty) return receipts;
    return receipts.where((receipt) {
      return receipt.merchant
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }
}
