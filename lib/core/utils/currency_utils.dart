import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Currency utility functions
class CurrencyUtils {
  /// Format amount as currency (e.g., '$123.45')
  static String formatAmount(double amount) {
    return '${AppConstants.currencySymbol}${amount.toStringAsFixed(2)}';
  }
  
  /// Format amount with thousands separator (e.g., '$1,234.56')
  static String formatAmountWithSeparator(double amount) {
    final formatter = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  /// Parse amount from string
  static double? parseAmount(String amountString) {
    try {
      // Remove currency symbol and whitespace
      final cleaned = amountString
          .replaceAll(AppConstants.currencySymbol, '')
          .replaceAll(',', '')
          .trim();
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }
  
  /// Validate amount
  static bool isValidAmount(String amountString) {
    final amount = parseAmount(amountString);
    return amount != null && amount > 0;
  }
  
  /// Round to 2 decimal places
  static double roundAmount(double amount) {
    return (amount * 100).round() / 100;
  }
}
