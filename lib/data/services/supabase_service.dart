import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/receipt_model.dart';

/// Service for Supabase database operations
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Create a new receipt in Supabase
  Future<Receipt> createReceipt(Receipt receipt) async {
    try {
      if (currentUserId == null) {
        throw AppAuthException(message: 'User not authenticated');
      }

      final response = await _client
          .from(SupabaseConstants.receiptsTable)
          .insert(receipt.toInsertJson())
          .select()
          .single();

      return Receipt.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException(
        message: 'Failed to create receipt: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppException(
        message: 'Unexpected error creating receipt: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get all receipts for current user
  Future<List<Receipt>> getReceipts({
    int limit = 20,
    int offset = 0,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (currentUserId == null) {
        throw AppAuthException(message: 'User not authenticated');
      }

      var query = _client
          .from(SupabaseConstants.receiptsTable)
          .select()
          .eq(SupabaseConstants.receiptUserId, currentUserId!);

      // Apply filters
      if (category != null) {
        query = query.eq(SupabaseConstants.receiptCategory, category);
      }

      if (startDate != null) {
        query = query.gte(SupabaseConstants.receiptDate, startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte(SupabaseConstants.receiptDate, endDate.toIso8601String());
      }

      // Apply ordering and pagination in final query
      final response = await query
          .order(SupabaseConstants.receiptDate, ascending: false)
          .range(offset, offset + limit - 1);
      return (response as List).map((json) => Receipt.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        message: 'Failed to fetch receipts: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppException(
        message: 'Unexpected error fetching receipts: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get a single receipt by ID
  Future<Receipt?> getReceiptById(String id) async {
    try {
      if (currentUserId == null) {
        throw AppAuthException(message: 'User not authenticated');
      }

      final response = await _client
          .from(SupabaseConstants.receiptsTable)
          .select()
          .eq(SupabaseConstants.receiptId, id)
          .eq(SupabaseConstants.receiptUserId, currentUserId!)
          .maybeSingle();

      if (response == null) return null;
      return Receipt.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException(
        message: 'Failed to fetch receipt: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppException(
        message: 'Unexpected error fetching receipt: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update an existing receipt
  Future<Receipt> updateReceipt(Receipt receipt) async {
    try {
      if (currentUserId == null) {
        throw AppAuthException(message: 'User not authenticated');
      }

      final response = await _client
          .from(SupabaseConstants.receiptsTable)
          .update(receipt.toUpdateJson())
          .eq(SupabaseConstants.receiptId, receipt.id)
          .eq(SupabaseConstants.receiptUserId, currentUserId!)
          .select()
          .single();

      return Receipt.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException(
        message: 'Failed to update receipt: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppException(
        message: 'Unexpected error updating receipt: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete a receipt
  Future<void> deleteReceipt(String id) async {
    try {
      if (currentUserId == null) {
        throw AppAuthException(message: 'User not authenticated');
      }

      await _client
          .from(SupabaseConstants.receiptsTable)
          .delete()
          .eq(SupabaseConstants.receiptId, id)
          .eq(SupabaseConstants.receiptUserId, currentUserId!);
    } on PostgrestException catch (e) {
      throw AppException(
        message: 'Failed to delete receipt: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppException(
        message: 'Unexpected error deleting receipt: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get receipts count for current user
  Future<int> getReceiptsCount({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (currentUserId == null) {
        throw AppAuthException(message: 'User not authenticated');
      }

      var query = _client
          .from(SupabaseConstants.receiptsTable)
          .select()
          .eq(SupabaseConstants.receiptUserId, currentUserId!);

      if (category != null) {
        query = query.eq(SupabaseConstants.receiptCategory, category);
      }

      if (startDate != null) {
        query = query.gte(SupabaseConstants.receiptDate, startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte(SupabaseConstants.receiptDate, endDate.toIso8601String());
      }

      final response = await query.count();
      return response.count;
    } on PostgrestException catch (e) {
      throw AppException(
        message: 'Failed to count receipts: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppException(
        message: 'Unexpected error counting receipts: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get total amount for a period
  Future<double> getTotalAmount({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    try {
      if (currentUserId == null) {
        throw AppAuthException(message: 'User not authenticated');
      }

      var query = _client
          .from(SupabaseConstants.receiptsTable)
          .select(SupabaseConstants.receiptAmount)
          .eq(SupabaseConstants.receiptUserId, currentUserId!);

      if (category != null) {
        query = query.eq(SupabaseConstants.receiptCategory, category);
      }

      if (startDate != null) {
        query = query.gte(SupabaseConstants.receiptDate, startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte(SupabaseConstants.receiptDate, endDate.toIso8601String());
      }

      final response = await query;
      
      double total = 0.0;
      for (final item in response) {
        total += (item[SupabaseConstants.receiptAmount] as num).toDouble();
      }

      return total;
    } on PostgrestException catch (e) {
      throw AppException(
        message: 'Failed to calculate total: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppException(
        message: 'Unexpected error calculating total: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
