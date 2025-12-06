import '../../data/models/parsed_receipt_data.dart';

/// Utility class for parsing receipt data from OCR text
class ReceiptParser {
  /// Parse receipt text to extract amount, date, and merchant
  static ParsedReceiptData parse(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    return ParsedReceiptData(
      amount: _extractAmount(text, lines),
      date: _extractDate(text, lines),
      merchant: _extractMerchant(lines),
      amountConfidence: _calculateAmountConfidence(text),
      dateConfidence: _calculateDateConfidence(text),
      merchantConfidence: _calculateMerchantConfidence(lines),
      rawText: text,
    );
  }

  /// Extract amount from text
  static double? _extractAmount(String text, List<String> lines) {
    final textLower = text.toLowerCase();
    
    // Priority 1: Look for TOTAL with amount (avoid CASH which is payment, not total)
    final totalPatterns = [
      RegExp(r'total[:\s]*(?:rm)?[\s]*([\$€£]?\s*\d{1,6}[,._]?\d{0,3}[,._]\d{2})', caseSensitive: false),
      RegExp(r'montant[:\s]*(?:rm)?[\s]*([\$€£]?\s*\d{1,6}[,._]?\d{0,3}[,._]\d{2})', caseSensitive: false),
      RegExp(r'somme[:\s]*(?:rm)?[\s]*([\$€£]?\s*\d{1,6}[,._]?\d{0,3}[,._]\d{2})', caseSensitive: false),
    ];
    
    for (final pattern in totalPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(RegExp(r'[\$€£,\s_]'), '').replaceAll('_', '.') ?? '';
        final amount = double.tryParse(amountStr);
        if (amount != null && amount > 0 && amount < 100000) {
          return amount;
        }
      }
    }
    
    // Priority 2: Look for amount near keywords (but NOT near CASH)
    final keywords = ['total', 'montant', 'sum', 'balance', 'due', 'pay', 'à payer'];
    final excludeKeywords = ['cash', 'paid', 'payment', 'change', 'tender'];
    
    for (final keyword in keywords) {
      final keywordIndex = textLower.indexOf(keyword);
      if (keywordIndex != -1) {
        // Check if CASH is nearby (within 20 chars) - if so, skip
        final nearbyText = text.substring(
          (keywordIndex - 20).clamp(0, text.length),
          (keywordIndex + 20).clamp(0, text.length),
        ).toLowerCase();
        
        if (excludeKeywords.any((exclude) => nearbyText.contains(exclude))) {
          continue; // Skip if near CASH/PAID/etc
        }
        
        // Look in next 100 characters
        final searchText = text.substring(
          keywordIndex,
          (keywordIndex + 100).clamp(0, text.length),
        );
        final amount = _findAmountInText(searchText);
        if (amount != null && amount > 0 && amount < 100000) {
          return amount;
        }
      }
    }
    
    // Priority 3: Find largest reasonable amount (avoid IDs/patent numbers)
    return _findLargestReasonableAmount(text);
  }

  /// Find amount pattern in text
  static double? _findAmountInText(String text) {
    // Pattern: optional currency symbol, digits, decimal point, 2 digits
    final patterns = [
      RegExp(r'[\$€£]?\s*(\d{1,6}[,.]?\d{0,3}\.?\d{2})'),
      RegExp(r'(\d{1,6}[,.]\d{2})'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
        return double.tryParse(amountStr);
      }
    }
    
    return null;
  }

  /// Find largest reasonable amount (avoid IDs, patent numbers, phone numbers)
  static double? _findLargestReasonableAmount(String text) {
    final pattern = RegExp(r'[\$€£]?\s*(\d{1,6}[,.]?\d{0,3}\.\d{2})');
    final matches = pattern.allMatches(text);
    
    double? largest;
    for (final match in matches) {
      final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
      final amount = double.tryParse(amountStr);
      
      // Filter out unreasonable amounts
      if (amount != null && amount > 0.50 && amount < 10000) {
        // Avoid numbers that look like IDs (too many digits before decimal)
        final beforeDecimal = amountStr.split('.')[0];
        if (beforeDecimal.length <= 5) {
          if (largest == null || amount > largest) {
            largest = amount;
          }
        }
      }
    }
    
    return largest;
  }

  /// Extract date from text
  static DateTime? _extractDate(String text, List<String> lines) {
    // Common date patterns - try most specific first
    final patterns = [
      // DD-MM-YYYY or DD/MM/YYYY (common in receipts)
      RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{4})'),
      // YYYY-MM-DD
      RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})'),
      // DD Month YYYY (English)
      RegExp(r'(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{2,4})', caseSensitive: false),
      // DD Month YYYY (French)
      RegExp(r'(\d{1,2})\s+(Janv|Févr|Mars|Avr|Mai|Juin|Juil|Août|Sept|Oct|Nov|Déc)[a-z]*\s+(\d{2,4})', caseSensitive: false),
      // MM/DD/YY or DD/MM/YY (2-digit year)
      RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{2})'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final date = _parseDate(match);
        if (date != null && _isReasonableDate(date)) {
          return date;
        }
      }
    }
    
    // Return null instead of today - let UI handle default
    return null;
  }
  
  /// Check if date is reasonable (not in future, not too old)
  static bool _isReasonableDate(DateTime date) {
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    final tomorrow = now.add(const Duration(days: 1));
    return date.isAfter(oneYearAgo) && date.isBefore(tomorrow);
  }

  /// Parse date from regex match
  static DateTime? _parseDate(RegExpMatch match) {
    try {
      final groups = match.groups([1, 2, 3]);
      if (groups.any((g) => g == null)) return null;
      
      // Try different date formats
      final part1 = int.tryParse(groups[0]!);
      final part2 = groups[1];
      final part3 = int.tryParse(groups[2]!);
      
      if (part1 == null || part3 == null) return null;
      
      // Check if part2 is a month name
      final monthNames = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
        'may': 5, 'jun': 6, 'jul': 7, 'aug': 8,
        'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
      };
      
      if (monthNames.containsKey(part2!.toLowerCase().substring(0, 3))) {
        final month = monthNames[part2.toLowerCase().substring(0, 3)]!;
        final year = part3 < 100 ? 2000 + part3 : part3;
        return DateTime(year, month, part1);
      }
      
      // Numeric date
      final part2Int = int.tryParse(part2);
      if (part2Int == null) return null;
      
      // Determine format based on values
      if (part1 > 1000) {
        // YYYY-MM-DD
        return DateTime(part1, part2Int, part3);
      } else if (part1 > 12) {
        // DD/MM/YYYY
        final year = part3 < 100 ? 2000 + part3 : part3;
        return DateTime(year, part2Int, part1);
      } else {
        // MM/DD/YYYY (US format)
        final year = part3 < 100 ? 2000 + part3 : part3;
        return DateTime(year, part1, part2Int);
      }
    } catch (e) {
      return null;
    }
  }

  /// Extract merchant name from text
  static String? _extractMerchant(List<String> lines) {
    if (lines.isEmpty) return null;
    
    // Merchant is usually in the first few lines
    final candidateLines = lines.take(8).toList();
    
    // Words that indicate this is NOT the merchant name
    final excludeWords = {
      'receipt', 'invoice', 'bill', 'total', 'tax', 'subtotal',
      'date', 'time', 'cashier', 'server', 'table', 'order',
      'address', 'adresse', 'rue', 'street', 'avenue', 'blvd',
      'city', 'ville', 'phone', 'tél', 'fax', 'email',
      'patente', 'license', 'permit', 'n°', 'no.', '#',
    };
    
    for (final line in candidateLines) {
      final lineLower = line.toLowerCase();
      final lineTrimmed = line.trim();
      
      // Skip very short lines
      if (lineTrimmed.length < 3) continue;
      
      // Skip lines with excluded words
      if (excludeWords.any((word) => lineLower.contains(word))) continue;
      
      // Skip lines with mostly numbers (addresses, phone numbers, IDs)
      final digitCount = RegExp(r'\d').allMatches(lineTrimmed).length;
      if (digitCount > lineTrimmed.length / 2) continue;
      
      // Skip lines that look like addresses (have numbers at start)
      if (RegExp(r'^\d+\s').hasMatch(lineTrimmed)) continue;
      
      // Skip lines with postal codes
      if (RegExp(r'[A-Z]\d[A-Z]\s?\d[A-Z]\d', caseSensitive: false).hasMatch(lineTrimmed)) continue;
      
      // Prefer lines with capital letters (business names often capitalized)
      final hasCapitals = RegExp(r'[A-Z]').hasMatch(lineTrimmed);
      if (hasCapitals && lineTrimmed.length >= 5) {
        return lineTrimmed;
      }
    }
    
    // Fallback to first non-numeric line
    for (final line in candidateLines) {
      final lineTrimmed = line.trim();
      if (lineTrimmed.length >= 3 && !RegExp(r'^\d').hasMatch(lineTrimmed)) {
        return lineTrimmed;
      }
    }
    
    // Last resort: first line
    return lines.first.trim();
  }

  /// Calculate confidence for amount extraction
  static double _calculateAmountConfidence(String text) {
    final textLower = text.toLowerCase();
    final hasTotal = textLower.contains('total');
    final hasAmount = textLower.contains('amount');
    final hasCurrency = RegExp(r'[\$€£]').hasMatch(text);
    
    double confidence = 0.3; // Base confidence
    if (hasTotal || hasAmount) confidence += 0.4;
    if (hasCurrency) confidence += 0.3;
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Calculate confidence for date extraction
  static double _calculateDateConfidence(String text) {
    final hasDatePattern = RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}').hasMatch(text);
    final hasMonthName = RegExp(r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)', caseSensitive: false).hasMatch(text);
    
    double confidence = 0.3; // Base confidence
    if (hasDatePattern) confidence += 0.4;
    if (hasMonthName) confidence += 0.3;
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Calculate confidence for merchant extraction
  static double _calculateMerchantConfidence(List<String> lines) {
    if (lines.isEmpty) return 0.0;
    
    // Higher confidence if first line looks like a business name
    final firstLine = lines.first.trim();
    final hasCapitals = RegExp(r'[A-Z]').allMatches(firstLine).length > firstLine.length / 3;
    final notMostlyNumbers = RegExp(r'\d').allMatches(firstLine).length < firstLine.length / 2;
    
    double confidence = 0.4; // Base confidence
    if (hasCapitals) confidence += 0.3;
    if (notMostlyNumbers) confidence += 0.3;
    
    return confidence.clamp(0.0, 1.0);
  }
}
