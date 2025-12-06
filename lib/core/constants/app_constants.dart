/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'TrustExpense';
  static const String appVersion = '1.0.0';
  
  // Categories
  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Health',
    'Services',
    'Housing',
    'Other',
  ];
  
  // Category Icons (Material Icons)
  static const Map<String, String> categoryIcons = {
    'Food': 'restaurant',
    'Transport': 'directions_car',
    'Entertainment': 'movie',
    'Shopping': 'shopping_bag',
    'Health': 'local_hospital',
    'Services': 'build',
    'Housing': 'home',
    'Other': 'category',
  };
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxMerchantNameLength = 50;
  static const int minMerchantNameLength = 3;
  
  // Performance
  static const int ocrTimeoutSeconds = 5;
  static const int classificationTimeoutMs = 200;
  static const int uploadTimeoutSeconds = 30;
  
  // Confidence Thresholds
  static const double highConfidenceThreshold = 0.8;
  static const double mediumConfidenceThreshold = 0.5;
  
  // Pagination
  static const int receiptsPerPage = 20;
  
  // Image
  static const int maxImageSizeBytes = 1024 * 1024; // 1MB
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  
  // Currency
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';
  
  // Default Values
  static const String unknownMerchant = 'Unknown Merchant';
  static const String defaultCategory = 'Other';
  
  // Amount Validation
  static const double minAmount = 0.01;
  static const double maxAmount = 999999.99;
}
