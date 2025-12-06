import 'package:intl/intl.dart';

/// Receipt model compatible with Supabase
class Receipt {
  final String id; // UUID from Supabase
  final String userId;
  final double amount;
  final DateTime date;
  final String merchant;
  final String category;
  final double categoryConfidence;
  final bool manualOverride;
  final String? imageUrl;
  final String? ocrText;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Receipt({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.merchant,
    required this.category,
    this.categoryConfidence = 0.0,
    this.manualOverride = false,
    this.imageUrl,
    this.ocrText,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Receipt from Supabase JSON
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      merchant: json['merchant'] as String,
      category: json['category'] as String,
      categoryConfidence: (json['category_confidence'] as num?)?.toDouble() ?? 0.0,
      manualOverride: json['manual_override'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      ocrText: json['ocr_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Receipt to Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'merchant': merchant,
      'category': category,
      'category_confidence': categoryConfidence,
      'manual_override': manualOverride,
      'image_url': imageUrl,
      'ocr_text': ocrText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create JSON for insert (without id, createdAt, updatedAt - Supabase handles these)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'merchant': merchant,
      'category': category,
      'category_confidence': categoryConfidence,
      'manual_override': manualOverride,
      'image_url': imageUrl,
      'ocr_text': ocrText,
    };
  }

  /// Create JSON for update (only updatable fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
      'merchant': merchant,
      'category': category,
      'category_confidence': categoryConfidence,
      'manual_override': manualOverride,
      'image_url': imageUrl,
      'ocr_text': ocrText,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Copy with method for creating modified copies
  Receipt copyWith({
    String? id,
    String? userId,
    double? amount,
    DateTime? date,
    String? merchant,
    String? category,
    double? categoryConfidence,
    bool? manualOverride,
    String? imageUrl,
    String? ocrText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      categoryConfidence: categoryConfidence ?? this.categoryConfidence,
      manualOverride: manualOverride ?? this.manualOverride,
      imageUrl: imageUrl ?? this.imageUrl,
      ocrText: ocrText ?? this.ocrText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Formatted amount with currency symbol
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  /// Formatted date
  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);

  /// Short formatted date
  String get shortFormattedDate => DateFormat('MM/dd/yy').format(date);

  @override
  String toString() {
    return 'Receipt(id: $id, merchant: $merchant, amount: $formattedAmount, date: $formattedDate, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Receipt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
