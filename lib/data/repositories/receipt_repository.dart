import 'dart:io';
import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../../core/errors/exceptions.dart';

/// Repository for managing receipt state
class ReceiptRepository with ChangeNotifier {
  final SupabaseService _supabaseService;
  final StorageService _storageService;

  ReceiptRepository(this._supabaseService, this._storageService);

  // State
  List<Receipt> _receipts = [];
  bool _isLoading = false;
  String? _error;
  int _totalCount = 0;

  // Getters
  List<Receipt> get receipts => _receipts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _totalCount;
  bool get hasReceipts => _receipts.isNotEmpty;

  /// Load receipts from Supabase
  Future<void> loadReceipts({
    int limit = 20,
    int offset = 0,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool append = false,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final fetchedReceipts = await _supabaseService.getReceipts(
        limit: limit,
        offset: offset,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );

      if (append) {
        _receipts.addAll(fetchedReceipts);
      } else {
        _receipts = fetchedReceipts;
      }

      // Get total count
      _totalCount = await _supabaseService.getReceiptsCount(
        category: category,
        startDate: startDate,
        endDate: endDate,
      );

      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Failed to load receipts: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Create a new receipt with image upload
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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = _supabaseService.currentUserId;
      if (userId == null) {
        throw AppAuthException(message: 'User not authenticated');
      }

      // Generate a temporary ID for the receipt (will be replaced by Supabase)
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();

      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _storageService.uploadReceiptImage(
          imageFile: imageFile,
          userId: userId,
          receiptId: tempId,
        );
      }

      // Create receipt object
      final receipt = Receipt(
        id: tempId, // Temporary, will be replaced
        userId: userId,
        amount: amount,
        date: date,
        merchant: merchant,
        category: category,
        categoryConfidence: categoryConfidence,
        manualOverride: manualOverride,
        imageUrl: imageUrl,
        ocrText: ocrText,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Supabase
      final createdReceipt = await _supabaseService.createReceipt(receipt);

      // Add to local list
      _receipts.insert(0, createdReceipt);
      _totalCount++;

      _isLoading = false;
      notifyListeners();

      return createdReceipt;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Failed to create receipt: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing receipt
  Future<Receipt> updateReceipt(Receipt receipt) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedReceipt = await _supabaseService.updateReceipt(receipt);

      // Update in local list
      final index = _receipts.indexWhere((r) => r.id == receipt.id);
      if (index != -1) {
        _receipts[index] = updatedReceipt;
      }

      _isLoading = false;
      notifyListeners();

      return updatedReceipt;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Failed to update receipt: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a receipt
  Future<void> deleteReceipt(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Find receipt to get image info
      final receipt = _receipts.firstWhere((r) => r.id == id);
      
      // Delete from Supabase
      await _supabaseService.deleteReceipt(id);

      // Delete image from storage if exists
      if (receipt.imageUrl != null) {
        try {
          await _storageService.deleteReceiptImage(
            userId: receipt.userId,
            receiptId: id,
          );
        } catch (e) {
          // Log but don't fail if image deletion fails
          debugPrint('Failed to delete image: $e');
        }
      }

      // Remove from local list
      _receipts.removeWhere((r) => r.id == id);
      _totalCount--;

      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Failed to delete receipt: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Get total amount for current receipts
  double getTotalAmount() {
    return _receipts.fold(0.0, (sum, receipt) => sum + receipt.amount);
  }

  /// Get receipts by category
  List<Receipt> getReceiptsByCategory(String category) {
    return _receipts.where((r) => r.category == category).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh receipts
  Future<void> refresh() async {
    await loadReceipts();
  }
}
