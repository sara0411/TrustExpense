/// Supabase-related constants
class SupabaseConstants {
  // These will be set after creating Supabase project
  static const String supabaseUrl = 'https://vccooivrvhxsvxayefkf.supabase.co'; // TODO: Update after setup
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjY29vaXZydmh4c3Z4YXllZmtmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwMzkwMzEsImV4cCI6MjA4MDYxNTAzMX0.O56KiLlsVaxPp641rdiG4qqPigiIUFF4gFfqPBnAN9A'; // TODO: Update after setup
  
  // Table Names
  static const String usersTable = 'users';
  static const String receiptsTable = 'receipts';
  static const String monthlySummariesTable = 'monthly_summaries';
  static const String blockchainProofsTable = 'blockchain_proofs';
  
  // Storage Buckets
  static const String receiptsBucket = 'receipts';
  static const String exportsBucket = 'exports';
  
  // Column Names - Users
  static const String userId = 'id';
  static const String userEmail = 'email';
  static const String userDisplayName = 'display_name';
  static const String userCreatedAt = 'created_at';
  static const String userUpdatedAt = 'updated_at';
  
  // Column Names - Receipts
  static const String receiptId = 'id';
  static const String receiptUserId = 'user_id';
  static const String receiptAmount = 'amount';
  static const String receiptDate = 'date';
  static const String receiptMerchant = 'merchant';
  static const String receiptCategory = 'category';
  static const String receiptCategoryConfidence = 'category_confidence';
  static const String receiptManualOverride = 'manual_override';
  static const String receiptImageUrl = 'image_url';
  static const String receiptOcrText = 'ocr_text';
  static const String receiptCreatedAt = 'created_at';
  static const String receiptUpdatedAt = 'updated_at';
  
  // Column Names - Monthly Summaries
  static const String summaryId = 'id';
  static const String summaryUserId = 'user_id';
  static const String summaryMonth = 'month';
  static const String summaryTotalAmount = 'total_amount';
  static const String summaryReceiptCount = 'receipt_count';
  static const String summaryCategoryBreakdown = 'category_breakdown';
  static const String summaryCanonicalJson = 'canonical_json';
  static const String summarySummaryHash = 'summary_hash';
  static const String summaryCreatedAt = 'created_at';
  
  // Column Names - Blockchain Proofs
  static const String proofId = 'id';
  static const String proofUserId = 'user_id';
  static const String proofSummaryId = 'summary_id';
  static const String proofMonth = 'month';
  static const String proofHash = 'hash';
  static const String proofTxId = 'tx_id';
  static const String proofBlockNumber = 'block_number';
  static const String proofTimestamp = 'timestamp';
  static const String proofNetworkName = 'network_name';
  static const String proofExplorerUrl = 'explorer_url';
  static const String proofStatus = 'status';
  static const String proofGasUsed = 'gas_used';
  static const String proofCreatedAt = 'created_at';
}
