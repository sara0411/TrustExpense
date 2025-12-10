import 'dart:io';
import 'package:flutter/foundation.dart';
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
      // Verify file exists
      if (!await imageFile.exists()) {
        throw AppStorageException(
          message: 'Image file does not exist at path: ${imageFile.path}',
        );
      }

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();
      final fileSize = bytes.length;
      
      debugPrint('📤 Uploading image: ${imageFile.path}');
      debugPrint('📦 File size: $fileSize bytes');

      // Generate file path: {userId}/{receiptId}.jpg
      final fileName = '$receiptId.jpg';
      final filePath = '$userId/$fileName';
      
      debugPrint('🗂️ Upload path: $filePath');
      debugPrint('🪣 Bucket: ${SupabaseConstants.receiptsBucket}');

      // Upload bytes to receipts bucket
      try {
        final uploadPath = await _client.storage
            .from(SupabaseConstants.receiptsBucket)
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: supabase.FileOptions(
                contentType: 'image/jpeg',
                upsert: true, // Allow overwriting if file exists
              ),
            );

        debugPrint('✅ Upload successful: $uploadPath');
      } catch (uploadError) {
        debugPrint('❌ Upload failed: $uploadError');
        rethrow;
      }

      // Get public URL
      final publicUrl = _client.storage
          .from(SupabaseConstants.receiptsBucket)
          .getPublicUrl(filePath);

      debugPrint('🔗 Public URL: $publicUrl');

      // Verify the URL is accessible (optional but helpful for debugging)
      if (publicUrl.isEmpty) {
        throw AppStorageException(
          message: 'Failed to generate public URL for uploaded image',
        );
      }

      return publicUrl;
    } on supabase.StorageException catch (e) {
      debugPrint('❌ Storage error: ${e.message}');
      debugPrint('❌ Status code: ${e.statusCode}');
      
      // Provide more specific error messages
      String errorMessage;
      if (e.statusCode == '404') {
        errorMessage = 'Storage bucket "${SupabaseConstants.receiptsBucket}" not found. Please create it in Supabase dashboard.';
      } else if (e.statusCode == '403') {
        errorMessage = 'Permission denied. Please check storage bucket policies in Supabase.';
      } else if (e.statusCode == '400') {
        errorMessage = 'Bad request. Please check if the bucket is public and policies are set correctly.';
      } else if (e.message?.contains('already exists') ?? false) {
        errorMessage = 'A file with this name already exists. Retrying with upsert...';
      } else {
        errorMessage = 'Failed to upload receipt image: ${e.message}';
      }
      
      throw AppStorageException(
        message: errorMessage,
        code: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
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
