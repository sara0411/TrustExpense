/// Certificate Model
/// 
/// Represents a blockchain certificate for a receipt.
/// Contains all data needed to verify receipt authenticity.

class ReceiptCertificate {
  /// Unique certificate ID (generated on-chain)
  final String certificateId;
  
  /// Receipt ID this certificate belongs to
  final String receiptId;
  
  /// SHA-256 hash of the receipt data
  final String receiptHash;
  
  /// Blockchain transaction hash
  final String? transactionHash;
  
  /// Block number where certificate was mined
  final int? blockNumber;
  
  /// Timestamp when certificate was created
  final DateTime certifiedAt;
  
  /// Blockchain network (e.g., 'polygon-mumbai')
  final String network;
  
  /// Address that certified the receipt
  final String certifierAddress;
  
  /// Verification status
  final CertificateStatus status;
  
  /// QR code data URL (for sharing/verification)
  final String? qrCodeUrl;
  
  ReceiptCertificate({
    required this.certificateId,
    required this.receiptId,
    required this.receiptHash,
    this.transactionHash,
    this.blockNumber,
    required this.certifiedAt,
    required this.network,
    required this.certifierAddress,
    this.status = CertificateStatus.pending,
    this.qrCodeUrl,
  });
  
  /// Create from JSON
  factory ReceiptCertificate.fromJson(Map<String, dynamic> json) {
    return ReceiptCertificate(
      certificateId: json['certificate_id'] as String,
      receiptId: json['receipt_id'] as String,
      receiptHash: json['receipt_hash'] as String,
      transactionHash: json['transaction_hash'] as String?,
      blockNumber: json['block_number'] as int?,
      certifiedAt: DateTime.parse(json['certified_at'] as String),
      network: json['network'] as String,
      certifierAddress: json['certifier_address'] as String,
      status: CertificateStatus.values.firstWhere(
        (e) => e.toString() == 'CertificateStatus.${json['status']}',
        orElse: () => CertificateStatus.pending,
      ),
      qrCodeUrl: json['qr_code_url'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'certificate_id': certificateId,
      'receipt_id': receiptId,
      'receipt_hash': receiptHash,
      'transaction_hash': transactionHash,
      'block_number': blockNumber,
      'certified_at': certifiedAt.toIso8601String(),
      'network': network,
      'certifier_address': certifierAddress,
      'status': status.toString().split('.').last,
      'qr_code_url': qrCodeUrl,
    };
  }
  
  /// Create a copy with updated fields
  ReceiptCertificate copyWith({
    String? certificateId,
    String? receiptId,
    String? receiptHash,
    String? transactionHash,
    int? blockNumber,
    DateTime? certifiedAt,
    String? network,
    String? certifierAddress,
    CertificateStatus? status,
    String? qrCodeUrl,
  }) {
    return ReceiptCertificate(
      certificateId: certificateId ?? this.certificateId,
      receiptId: receiptId ?? this.receiptId,
      receiptHash: receiptHash ?? this.receiptHash,
      transactionHash: transactionHash ?? this.transactionHash,
      blockNumber: blockNumber ?? this.blockNumber,
      certifiedAt: certifiedAt ?? this.certifiedAt,
      network: network ?? this.network,
      certifierAddress: certifierAddress ?? this.certifierAddress,
      status: status ?? this.status,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
    );
  }
  
  /// Check if certificate is confirmed on blockchain
  bool get isConfirmed => status == CertificateStatus.confirmed;
  
  /// Get blockchain explorer URL for this certificate
  String get explorerUrl {
    if (transactionHash == null) return '';
    return 'https://mumbai.polygonscan.com/tx/$transactionHash';
  }
}

/// Certificate status enum
enum CertificateStatus {
  /// Certificate is being created
  pending,
  
  /// Transaction submitted to blockchain
  submitted,
  
  /// Transaction confirmed on blockchain
  confirmed,
  
  /// Certificate verification failed
  failed,
  
  /// Certificate has been revoked
  revoked,
}

/// Extension for status display
extension CertificateStatusExtension on CertificateStatus {
  String get displayName {
    switch (this) {
      case CertificateStatus.pending:
        return 'Pending';
      case CertificateStatus.submitted:
        return 'Submitted';
      case CertificateStatus.confirmed:
        return 'Confirmed';
      case CertificateStatus.failed:
        return 'Failed';
      case CertificateStatus.revoked:
        return 'Revoked';
    }
  }
  
  String get icon {
    switch (this) {
      case CertificateStatus.pending:
        return '⏳';
      case CertificateStatus.submitted:
        return '📤';
      case CertificateStatus.confirmed:
        return '✅';
      case CertificateStatus.failed:
        return '❌';
      case CertificateStatus.revoked:
        return '🚫';
    }
  }
}
