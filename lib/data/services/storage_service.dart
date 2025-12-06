import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/constants/supabase_constants.dart';
import '../../core/errors/exceptions.dart';

/// Service for Supabase Storage operations
class StorageService {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  /// Upload receipt image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadReceiptImage({
    required File imageFile,
    required String userId,
    required String receiptId,
  }) async {
    try {
      // Generate file path: receipts/{userId}/{receiptId}.jpg
      final fileName = '$receiptId.jpg';
      final filePath = '$userId/$fileName';

      // Upload file to receipts bucket
      await _client.storage
          .from(SupabaseConstants.receiptsBucket)
          .upload(
            filePath,
            imageFile,
          );

      // Get public URL
      final publicUrl = _client.storage
          .from(SupabaseConstants.receiptsBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } on supabase.StorageException catch (e) {
      throw AppStorageException(
        message: 'Failed to upload receipt image: ${e.message}',
        code: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AppStorageException(
        message: 'Unexpected error uploading image: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete receipt image from Supabase Storage
  Future<void> deleteReceiptImage({
    required String userId,
    required String receiptId,
  }) async {
    try {
      final fileName = '$receiptId.jpg';
      final filePath = '$userId/$fileName';

      await _client.storage
          .from(SupabaseConstants.receiptsBucket)
          .remove([filePath]);
    } on supabase.StorageException catch (e) {
      throw AppStorageException(
        message: 'Failed to delete receipt image: ${e.message}',
        code: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AppStorageException(
        message: 'Unexpected error deleting image: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Upload PDF export to Supabase Storage
  Future<String> uploadPdfExport({
    required File pdfFile,
    required String userId,
    required String month, // Format: YYYY-MM
  }) async {
    try {
      final fileName = 'monthly_report_$month.pdf';
      final filePath = '$userId/$fileName';

      await _client.storage
          .from(SupabaseConstants.exportsBucket)
          .upload(
            filePath,
            pdfFile,
          );

      final publicUrl = _client.storage
          .from(SupabaseConstants.exportsBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } on supabase.StorageException catch (e) {
      throw AppStorageException(
        message: 'Failed to upload PDF: ${e.message}',
        code: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AppStorageException(
        message: 'Unexpected error uploading PDF: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      throw AppStorageException(
        message: 'Failed to get file size: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Check if file exists in storage
  Future<bool> fileExists({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final files = await _client.storage.from(bucket).list(path: filePath);
      return files.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
