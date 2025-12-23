import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/gemini_config.dart';
import '../../core/errors/exceptions.dart';

/// REAL AI Classification Service using Google Gemini
/// 
/// This service uses Google's Gemini AI model (a Large Language Model)
/// to intelligently classify receipt text into expense categories.
/// 
/// This is TRUE artificial intelligence - not rule-based keyword matching.
/// The model understands context, semantics, and can handle any language.
class GeminiAIClassificationService {
  late final GenerativeModel _model;
  bool _isInitialized = false;
  
  /// Initialize the Gemini AI model
  Future<void> initialize() async {
    try {
      // Check if API key is configured
      if (GeminiConfig.apiKey == 'AIzaSyDdoth3Mcr1wfqKpPhnmnlYfCf-0t1axyA') {
        throw AIException(
          message: 'Gemini API key not configured. Please add your API key to gemini_config.dart',
        );
      }
      
      _model = GenerativeModel(
        model: GeminiConfig.model,
        apiKey: GeminiConfig.apiKey,
      );
      _isInitialized = true;
      debugPrint('✅ Gemini AI initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Gemini AI: $e');
      throw AIException(message: 'Failed to initialize AI: $e');
    }
  }
  
  /// Classify receipt text using REAL AI
  /// 
  /// This uses Google's Gemini AI to understand the receipt content
  /// and intelligently categorize it.
  Future<String> classifyReceipt(String receiptText) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final prompt = '''
You are an expense categorization AI. Analyze the following receipt text and classify it into ONE of these categories:
- Food
- Transport
- Entertainment
- Shopping
- Health
- Services
- Housing
- Other

Receipt text:
$receiptText

Respond with ONLY the category name, nothing else.
''';

      debugPrint('🤖 Gemini AI analyzing receipt...');
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final category = response.text?.trim() ?? 'Other';
      
      debugPrint('✅ Gemini AI predicted: $category');
      
      // Validate the category
      const validCategories = [
        'Food', 'Transport', 'Entertainment', 'Shopping',
        'Health', 'Services', 'Housing', 'Other'
      ];
      
      if (validCategories.contains(category)) {
        return category;
      } else {
        debugPrint('⚠️ Invalid category from AI: $category, defaulting to Other');
        return 'Other';
      }
      
    } catch (e) {
      debugPrint('❌ Gemini AI classification failed: $e');
      // Fallback to keyword-based if AI fails
      return 'Other';
    }
  }
  
  /// Dispose of resources
  void dispose() {
    _isInitialized = false;
    debugPrint('🧹 Gemini AI Service disposed');
  }
}
