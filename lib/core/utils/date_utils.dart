import 'package:intl/intl.dart';

/// Date utility functions
class DateUtils {
  /// Format date as 'MMM dd, yyyy' (e.g., 'Dec 06, 2025')
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  /// Format date as 'yyyy-MM-dd' (e.g., '2025-12-06')
  static String formatDateISO(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// Format date as 'yyyy-MM' for monthly summaries (e.g., '2025-12')
  static String formatMonth(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }
  
  /// Format date as 'MMMM yyyy' for display (e.g., 'December 2025')
  static String formatMonthDisplay(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
  
  /// Format timestamp as 'MMM dd, yyyy HH:mm' (e.g., 'Dec 06, 2025 16:30')
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
  
  /// Parse date from string (yyyy-MM-dd)
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Get first day of month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// Get last day of month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }
  
  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Get relative time string (e.g., 'Today', 'Yesterday', '2 days ago')
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
