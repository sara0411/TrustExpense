import '../constants/app_constants.dart';

/// Input validation utilities
class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    return null;
  }
  
  /// Validate merchant name
  static String? validateMerchant(String? value) {
    if (value == null || value.isEmpty) {
      return 'Merchant name is required';
    }
    
    if (value.length < AppConstants.minMerchantNameLength) {
      return 'Merchant name must be at least ${AppConstants.minMerchantNameLength} characters';
    }
    
    if (value.length > AppConstants.maxMerchantNameLength) {
      return 'Merchant name must be less than ${AppConstants.maxMerchantNameLength} characters';
    }
    
    return null;
  }
  
  /// Validate amount
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
