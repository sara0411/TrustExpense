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
    await _repository.refresh();
    notifyListeners();
  }
}
