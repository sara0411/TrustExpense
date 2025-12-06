/// Firebase-related constants
class FirebaseConstants {
  // Collection Names
  static const String usersCollection = 'users';
  static const String receiptsCollection = 'receipts';
  static const String monthlySummariesCollection = 'monthlySummaries';
  static const String blockchainProofsCollection = 'blockchainProofs';
  
  // Storage Paths
  static const String receiptsStoragePath = 'receipts';
  static const String exportsStoragePath = 'exports';
  
  // Field Names - Users
  static const String userEmail = 'email';
  static const String userDisplayName = 'displayName';
  static const String userCreatedAt = 'createdAt';
  static const String userLastLogin = 'lastLogin';
  
  // Field Names - Receipts
  static const String receiptUserId = 'userId';
  static const String receiptAmount = 'amount';
  static const String receiptDate = 'date';
  static const String receiptMerchant = 'merchant';
  static const String receiptCategory = 'category';
  static const String receiptCategoryConfidence = 'categoryConfidence';
  static const String receiptManualOverride = 'manualOverride';
  static const String receiptImageUrl = 'imageUrl';
  static const String receiptOcrText = 'ocrText';
  static const String receiptCreatedAt = 'createdAt';
  static const String receiptUpdatedAt = 'updatedAt';
  
  // Field Names - Monthly Summaries
  static const String summaryUserId = 'userId';
  static const String summaryMonth = 'month';
  static const String summaryTotalAmount = 'totalAmount';
  static const String summaryReceiptCount = 'receiptCount';
  static const String summaryCategoryBreakdown = 'categoryBreakdown';
  static const String summaryCanonicalJson = 'canonicalJson';
  static const String summarySummaryHash = 'summaryHash';
  static const String summaryCreatedAt = 'createdAt';
  
  // Field Names - Blockchain Proofs
  static const String proofUserId = 'userId';
  static const String proofSummaryId = 'summaryId';
  static const String proofMonth = 'month';
  static const String proofHash = 'hash';
  static const String proofTxId = 'txId';
  static const String proofBlockNumber = 'blockNumber';
  static const String proofTimestamp = 'timestamp';
  static const String proofNetworkName = 'networkName';
  static const String proofExplorerUrl = 'explorerUrl';
  static const String proofStatus = 'status';
  static const String proofGasUsed = 'gasUsed';
  static const String proofCreatedAt = 'createdAt';
}
