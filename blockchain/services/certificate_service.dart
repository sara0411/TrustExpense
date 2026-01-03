/// Certificate Service
/// 
/// Handles certificate generation, hashing, and QR code creation.
/// Works with BlockchainService to create blockchain-backed certificates.
/// 
/// IMPORTANT: Copy this file to lib/data/services/certificate_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

// Import your models
// import '../models/receipt.dart';
// import '../models/certificate.dart';

class CertificateService {
  /// Generate SHA-256 hash from receipt data
  /// 
  /// Creates a deterministic hash from receipt fields.
  /// The hash represents the "fingerprint" of the receipt.
  /// 
  /// @param receipt The receipt to hash
  /// @return Hex-encoded SHA-256 hash
  String generateReceiptHash(dynamic receipt) {
    // Create canonical JSON representation
    final canonicalData = {
      'id': receipt.id,
      'user_id': receipt.userId,
      'merchant': receipt.merchant,
      'amount': receipt.amount.toStringAsFixed(2),
      'date': receipt.date.toIso8601String(),
      'category': receipt.category,
      // Include OCR text for tamper detection
      'ocr_text': receipt.ocrText ?? '',
    };
    
    // Sort keys for deterministic hashing
    final sortedKeys = canonicalData.keys.toList()..sort();
    final sortedData = {
      for (var key in sortedKeys) key: canonicalData[key]
    };
    
    // Convert to JSON string
    final jsonString = jsonEncode(sortedData);
    
    // Generate SHA-256 hash
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    
    // Return as hex string with 0x prefix
    return '0x${digest.toString()}';
  }
  
  /// Verify receipt hash matches stored certificate
  /// 
  /// Recomputes the hash and compares with certificate
  /// 
  /// @param receipt The receipt to verify
  /// @param certificateHash The stored certificate hash
  /// @return True if hashes match
  bool verifyReceiptHash(dynamic receipt, String certificateHash) {
    final computedHash = generateReceiptHash(receipt);
    return computedHash.toLowerCase() == certificateHash.toLowerCase();
  }
  
  /// Generate QR code for certificate verification
  /// 
  /// Creates a QR code containing certificate data for easy verification
  /// 
  /// @param certificate The certificate to encode
  /// @return QR code widget
  Widget generateQRCode(dynamic certificate, {double size = 200}) {
    // Create verification payload
    final qrData = jsonEncode({
      'certificate_id': certificate.certificateId,
      'receipt_id': certificate.receiptId,
      'receipt_hash': certificate.receiptHash,
      'tx_hash': certificate.transactionHash,
      'network': certificate.network,
      'certified_at': certificate.certifiedAt.toIso8601String(),
    });
    
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );
  }
  
  /// Parse QR code data
  /// 
  /// Decodes QR code data back into certificate information
  /// 
  /// @param qrData The scanned QR code data
  /// @return Parsed certificate data
  Map<String, dynamic> parseQRCode(String qrData) {
    try {
      return jsonDecode(qrData) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Invalid QR code data: $e');
    }
  }
  
  /// Generate certificate ID from transaction hash
  /// 
  /// Creates a unique certificate ID based on the blockchain transaction
  /// 
  /// @param txHash Transaction hash
  /// @param receiptId Receipt ID
  /// @return Certificate ID
  String generateCertificateId(String txHash, String receiptId) {
    final combined = '$txHash:$receiptId';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return '0x${digest.toString()}';
  }
  
  /// Truncate hash for display
  /// 
  /// Shows first and last 6 characters of hash
  /// Example: 0x1234...abcd
  /// 
  /// @param hash Full hash string
  /// @return Truncated hash
  String truncateHash(String hash, {int length = 6}) {
    if (hash.length <= length * 2 + 5) return hash;
    
    final start = hash.substring(0, length + 2); // Include 0x
    final end = hash.substring(hash.length - length);
    return '$start...$end';
  }
  
  /// Format timestamp for display
  /// 
  /// @param timestamp DateTime to format
  /// @return Formatted string
  String formatCertificateDate(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
           '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}';
  }
  
  /// Get certificate status color
  /// 
  /// @param status Certificate status
  /// @return Color for UI display
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
      case 'submitted':
        return Colors.orange;
      case 'failed':
      case 'revoked':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  /// Validate certificate data integrity
  /// 
  /// Checks if all required fields are present and valid
  /// 
  /// @param certificate Certificate to validate
  /// @return Validation result
  CertificateValidation validateCertificate(dynamic certificate) {
    final errors = <String>[];
    
    // Check required fields
    if (certificate.certificateId.isEmpty) {
      errors.add('Missing certificate ID');
    }
    
    if (certificate.receiptHash.isEmpty) {
      errors.add('Missing receipt hash');
    }
    
    if (!certificate.receiptHash.startsWith('0x')) {
      errors.add('Invalid hash format');
    }
    
    if (certificate.receiptHash.length != 66) { // 0x + 64 hex chars
      errors.add('Invalid hash length');
    }
    
    if (certificate.transactionHash != null &&
        !certificate.transactionHash!.startsWith('0x')) {
      errors.add('Invalid transaction hash format');
    }
    
    return CertificateValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// Certificate validation result
class CertificateValidation {
  final bool isValid;
  final List<String> errors;
  
  CertificateValidation({
    required this.isValid,
    required this.errors,
  });
  
  String get errorMessage => errors.join(', ');
}
