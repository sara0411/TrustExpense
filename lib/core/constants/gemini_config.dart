/// Google Gemini AI Configuration
/// 
/// This file contains the API key for Google's Gemini AI service.
/// The API key is used for intelligent receipt text classification.
class GeminiConfig {
  /// Gemini API Key
  /// 
  /// Get your free API key from: https://makersuite.google.com/app/apikey
  static const String apiKey = 'AIzaSyDdoth3Mcr1wfqKpPhnmnlYfCf-0t1axyA';
  
  /// Model to use for text classification
  static const String model = 'gemini-pro';
  
  /// Maximum tokens for response
  static const int maxTokens = 100;
  
  /// Temperature for response generation (0.0 = deterministic, 1.0 = creative)
  static const double temperature = 0.1; // Low temperature for consistent categorization
}
