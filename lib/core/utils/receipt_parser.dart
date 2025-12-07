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

  /// Extract amount using semantic scoring - find the most likely total
  static double? _extractAmount(String text, List<String> lines) {
    final candidates = <AmountCandidate>[];
    
    // Collect ALL amounts from the receipt with context
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final amount = _extractAmountFromLine(line);
      
      if (amount != null && amount > 0.50 && amount < 100000) {
        // Get context: current line + previous 2 lines + next 2 lines
        final contextLines = <String>[];
        for (int j = (i - 2).clamp(0, lines.length); j < (i + 3).clamp(0, lines.length); j++) {
          contextLines.add(lines[j].toLowerCase());
        }
        final context = contextLines.join(' ');
        
        candidates.add(AmountCandidate(
          amount: amount,
          lineIndex: i,
          context: context,
          line: line.toLowerCase(),
        ));
      }
    }
    
    if (candidates.isEmpty) return null;
    
    // Score each candidate
    for (final candidate in candidates) {
      candidate.score = _scoreAmountCandidate(candidate, candidates);
    }
    
    // Sort by score (highest first)
    candidates.sort((a, b) => b.score.compareTo(a.score));
    
    // Return the highest scoring amount
    return candidates.first.amount;
  }
  
  /// Score an amount candidate - higher score = more likely to be the total
  static double _scoreAmountCandidate(AmountCandidate candidate, List<AmountCandidate> allCandidates) {
    double score = 0.0;
    
    final context = candidate.context;
    final line = candidate.line;
    
    // POSITIVE SIGNALS (increase score)
    
    // Strong total indicators
    if (context.contains('total includes') || context.contains('grand total')) {
      score += 100.0; // Highest priority
    } else if (line.contains('total') && !line.contains('total qty')) {
      score += 50.0;
    } else if (context.contains('total') && !context.contains('total qty')) {
      score += 30.0;
    }
    
    // Other total-like keywords
    if (context.contains('amount due') || context.contains('net amount') || 
        context.contains('balance due') || context.contains('payable')) {
      score += 40.0;
    }
    
    // Has currency symbol or RM
    if (line.contains('rm ') || line.contains('rm\t')) {
      score += 10.0;
    }
    
    // Amount is in a reasonable range for a receipt total (not too small, not huge)
    if (candidate.amount >= 5.0 && candidate.amount <= 1000.0) {
      score += 15.0;
    } else if (candidate.amount > 1000.0) {
      score -= 20.0; // Very large amounts are suspicious
    }
    
    // Amount appears in the middle to lower part of receipt (totals rarely at top)
    final positionRatio = candidate.lineIndex / allCandidates.length;
    if (positionRatio > 0.3 && positionRatio < 0.9) {
      score += 10.0;
    }
    
    // NEGATIVE SIGNALS (decrease score)
    
    // Explicit exclusions
    if (context.contains('cash') && !context.contains('cashier')) {
      score -= 25.0; // Cash payment, not total
    }
    
    if (context.contains('change')) {
      score -= 30.0; // Change given, not total
    }
    
    if (context.contains('tender') || context.contains('payment')) {
      score -= 20.0;
    }
    
    // Tax amounts
    if (context.contains('tax') && candidate.amount < 20.0) {
      score -= 40.0; // Small tax amounts
    }
    
    if (context.contains('gst') && candidate.amount < 5.0) {
      score -= 30.0; // GST amounts are usually small
    }
    
    // Quantity lines
    if (line.contains('qty') || line.contains('quantity') || context.contains('total qty')) {
      score -= 50.0;
    }
    
    // Very small amounts (likely item prices or taxes)
    if (candidate.amount < 2.0) {
      score -= 25.0;
    }
    
    // Round numbers might be cash payments (but not always, so small penalty)
    if (candidate.amount % 10 == 0 && candidate.amount > 20.0) {
      score -= 5.0;
    }
    
    // If this is the largest amount and there's a larger cash/change amount, boost it
    final sortedAmounts = allCandidates.map((c) => c.amount).toList()..sort();
    if (sortedAmounts.length >= 3 && candidate.amount == sortedAmounts[sortedAmounts.length - 2]) {
      // This is second largest - often the actual total when largest is cash
      score += 15.0;
    }
    
    return score;
  }

  /// Extract amount from a single line
  /// Accepts both . and - as decimal separator (for OCR errors)
  static double? _extractAmountFromLine(String line) {
    // Skip lines that look like dates to avoid false matches
    if (RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}').hasMatch(line)) {
      // This line contains a date pattern, only match if it has RM or currency symbol
      final rmPattern = RegExp(r'rm\s*(\d{1,6}(?:,\d{3})*[\.\-]\d{2})', caseSensitive: false);
      final rmMatch = rmPattern.firstMatch(line);
      if (rmMatch != null) {
        final amountStr = rmMatch.group(1)?.replaceAll(',', '').replaceAll('-', '.') ?? '';
        return double.tryParse(amountStr);
      }
      
      final currencyPattern = RegExp(r'[\$€£]\s*(\d{1,6}(?:,\d{3})*[\.\-]\d{2})');
      final currencyMatch = currencyPattern.firstMatch(line);
      if (currencyMatch != null) {
        final amountStr = currencyMatch.group(1)?.replaceAll(',', '').replaceAll('-', '.') ?? '';
        return double.tryParse(amountStr);
      }
      
      return null;
    }
    
    // Look for RM followed by amount
    final rmPattern = RegExp(r'rm\s*(\d{1,6}(?:,\d{3})*[\.\-]\d{2})', caseSensitive: false);
    final rmMatch = rmPattern.firstMatch(line);
    if (rmMatch != null) {
      final amountStr = rmMatch.group(1)?.replaceAll(',', '').replaceAll('-', '.') ?? '';
      return double.tryParse(amountStr);
    }
    
    // Look for currency symbol followed by amount
    final currencyPattern = RegExp(r'[\$€£]\s*(\d{1,6}(?:,\d{3})*[\.\-]\d{2})');
    final currencyMatch = currencyPattern.firstMatch(line);
    if (currencyMatch != null) {
      final amountStr = currencyMatch.group(1)?.replaceAll(',', '').replaceAll('-', '.') ?? '';
      return double.tryParse(amountStr);
    }
    
    // Look for plain decimal number with period only
    final decimalPattern = RegExp(r'(\d{1,6}(?:,\d{3})*\.\d{2})');
    final decimalMatch = decimalPattern.firstMatch(line);
    if (decimalMatch != null) {
      final amountStr = decimalMatch.group(1)?.replaceAll(',', '') ?? '';
      return double.tryParse(amountStr);
    }
    
    return null;
  }

  /// Extract date from text
  static DateTime? _extractDate(String text, List<String> lines) {
    for (final line in lines) {
      final date = _extractDateFromLine(line);
      if (date != null && _isReasonableDate(date)) {
        return date;
      }
    }
    
    final patterns = [
      RegExp(r'(?:Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|Mon|Tue|Wed|Thu|Fri|Sat|Sun)[,\s]+(\d{1,2})[-/](\d{1,2})[-/](\d{4})', caseSensitive: false),
      RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{4})'),
      RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})'),
      RegExp(r'(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{2,4})', caseSensitive: false),
      RegExp(r'(\d{1,2})\s+(Janv|Févr|Mars|Avr|Mai|Juin|Juil|Août|Sept|Oct|Nov|Déc)[a-z]*\s+(\d{2,4})', caseSensitive: false),
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
    
    return null;
  }

  static DateTime? _extractDateFromLine(String line) {
    final patterns = [
      RegExp(r'(?:Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|Mon|Tue|Wed|Thu|Fri|Sat|Sun)[,\s]+(\d{1,2})[-/](\d{1,2})[-/](\d{4})', caseSensitive: false),
      RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{4})'),
      RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})'),
      RegExp(r'(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{2,4})', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final date = _parseDate(match);
        if (date != null && _isReasonableDate(date)) {
          return date;
        }
      }
    }
    
    return null;
  }

  static bool _isReasonableDate(DateTime date) {
    final now = DateTime.now();
    final tenYearsAgo = now.subtract(const Duration(days: 365 * 10));
    final tomorrow = now.add(const Duration(days: 1));
    
    return date.isAfter(tenYearsAgo) && date.isBefore(tomorrow);
  }

  static DateTime? _parseDate(RegExpMatch match) {
    try {
      final groups = match.groups([1, 2, 3]);
      if (groups.any((g) => g == null)) return null;
      
      final part1 = int.tryParse(groups[0]!);
      final part2 = groups[1];
      final part3 = int.tryParse(groups[2]!);
      
      if (part1 == null || part3 == null) return null;
      
      final monthNames = {
        'jan': 1, 'janv': 1,
        'feb': 2, 'févr': 2, 'fev': 2,
        'mar': 3, 'mars': 3,
        'apr': 4, 'avr': 4,
        'may': 5, 'mai': 5,
        'jun': 6, 'juin': 6,
        'jul': 7, 'juil': 7,
        'aug': 8, 'aoû': 8, 'aou': 8,
        'sep': 9, 'sept': 9,
        'oct': 10,
        'nov': 11,
        'dec': 12, 'déc': 12,
      };
      
      final monthKey = part2!.toLowerCase().substring(0, part2.length < 3 ? part2.length : 3);
      if (monthNames.containsKey(monthKey)) {
        final month = monthNames[monthKey]!;
        final year = part3 < 100 ? 2000 + part3 : part3;
        if (part1 < 1 || part1 > 31) return null;
        return DateTime(year, month, part1);
      }
      
      final part2Int = int.tryParse(part2);
      if (part2Int == null) return null;
      
      if (part1 > 1000) {
        if (part2Int < 1 || part2Int > 12 || part3 < 1 || part3 > 31) return null;
        return DateTime(part1, part2Int, part3);
      } else {
        final year = part3 < 100 ? 2000 + part3 : part3;
        if (part1 < 1 || part1 > 31 || part2Int < 1 || part2Int > 12) return null;
        return DateTime(year, part2Int, part1);
      }
    } catch (e) {
      return null;
    }
  }

  static String? _extractMerchant(List<String> lines) {
    if (lines.isEmpty) return null;
    
    final candidateLines = lines.take(8).toList();
    
    final excludeWords = {
      'receipt', 'invoice', 'bill', 'total', 'tax', 'subtotal',
      'date', 'time', 'cashier', 'server', 'table', 'order',
      'address', 'adresse', 'rue', 'street', 'avenue', 'blvd',
      'city', 'ville', 'phone', 'tél', 'tel', 'fax', 'email',
      'patente', 'license', 'permit', 'n°', 'no.', '#',
      'gst', 'reg', 'registration', 'br no',
    };
    
    for (final line in candidateLines) {
      final lineLower = line.toLowerCase();
      final lineTrimmed = line.trim();
      
      if (lineTrimmed.length < 3) continue;
      if (excludeWords.any((word) => lineLower.contains(word))) continue;
      
      final digitCount = RegExp(r'\d').allMatches(lineTrimmed).length;
      if (digitCount > lineTrimmed.length / 2) continue;
      if (RegExp(r'^\d+\s').hasMatch(lineTrimmed)) continue;
      if (RegExp(r'[A-Z]\d[A-Z]\s?\d[A-Z]\d', caseSensitive: false).hasMatch(lineTrimmed)) continue;
      
      if (lineTrimmed.contains('(') && lineTrimmed.contains(')')) continue;
      
      final hasCapitals = RegExp(r'[A-Z]').hasMatch(lineTrimmed);
      if (hasCapitals && lineTrimmed.length >= 5) {
        return lineTrimmed;
      }
    }
    
    for (final line in candidateLines) {
      final lineTrimmed = line.trim();
      if (lineTrimmed.length >= 3 && !RegExp(r'^\d').hasMatch(lineTrimmed)) {
        return lineTrimmed;
      }
    }
    
    return lines.first.trim();
  }

  static double _calculateAmountConfidence(String text) {
    final textLower = text.toLowerCase();
    
    final hasTotal = textLower.contains('total');
    final hasAmount = textLower.contains('amount');
    final hasCurrency = RegExp(r'[\$€£]|rm', caseSensitive: false).hasMatch(text);
    final hasDecimal = RegExp(r'\d+[.-]\d{2}').hasMatch(text);
    
    double confidence = 0.2;
    if (hasTotal || hasAmount) confidence += 0.4;
    if (hasCurrency) confidence += 0.2;
    if (hasDecimal) confidence += 0.2;
    
    return confidence.clamp(0.0, 1.0);
  }

  static double _calculateDateConfidence(String text) {
    final hasDatePattern = RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}').hasMatch(text);
    final hasMonthName = RegExp(r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)', caseSensitive: false).hasMatch(text);
    final hasDateKeyword = RegExp(r'\bdate\b', caseSensitive: false).hasMatch(text);
    final hasDayName = RegExp(r'(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)', caseSensitive: false).hasMatch(text);
    
    double confidence = 0.2;
    if (hasDatePattern) confidence += 0.3;
    if (hasMonthName) confidence += 0.2;
    if (hasDateKeyword) confidence += 0.1;
    if (hasDayName) confidence += 0.2;
    
    return confidence.clamp(0.0, 1.0);
  }

  static double _calculateMerchantConfidence(List<String> lines) {
    if (lines.isEmpty) return 0.0;
    
    final firstLine = lines.first.trim();
    final hasCapitals = RegExp(r'[A-Z]').allMatches(firstLine).length > firstLine.length / 3;
    final notMostlyNumbers = RegExp(r'\d').allMatches(firstLine).length < firstLine.length / 2;
    
    double confidence = 0.4;
    if (hasCapitals) confidence += 0.3;
    if (notMostlyNumbers) confidence += 0.3;
    
    return confidence.clamp(0.0, 1.0);
  }
}

/// Helper class to store amount candidates with their context
class AmountCandidate {
  final double amount;
  final int lineIndex;
  final String context;
  final String line;
  double score = 0.0;
  
  AmountCandidate({
    required this.amount,
    required this.lineIndex,
    required this.context,
    required this.line,
  });
}