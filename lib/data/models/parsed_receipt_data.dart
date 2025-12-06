/// Parsed receipt data from OCR
class ParsedReceiptData {
  final double? amount;
  final DateTime? date;
  final String? merchant;
  final double amountConfidence;
  final double dateConfidence;
  final double merchantConfidence;
  final String rawText;

  const ParsedReceiptData({
    this.amount,
    this.date,
    this.merchant,
    required this.amountConfidence,
    required this.dateConfidence,
    required this.merchantConfidence,
    required this.rawText,
  });

  bool get hasAmount => amount != null && amountConfidence > 0.5;
  bool get hasDate => date != null && dateConfidence > 0.5;
  bool get hasMerchant => merchant != null && merchantConfidence > 0.5;
  bool get isComplete => hasAmount && hasDate && hasMerchant;
}
