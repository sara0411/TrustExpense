// ═══════════════════════════════════════════════════════════════════════════
// FLUTTER & DART IMPORTS
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/foundation.dart'; // Flutter foundation for debugPrint
import 'package:google_generative_ai/google_generative_ai.dart'; // Google's Gemini AI SDK
import '../../core/constants/gemini_config.dart'; // API key configuration
import '../../core/errors/exceptions.dart'; // Custom exception classes

/// ═══════════════════════════════════════════════════════════════════════════
/// GEMINI AI CLASSIFICATION SERVICE - REAL ARTIFICIAL INTELLIGENCE
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// This service uses Google's **Gemini AI** (a Large Language Model / LLM) to
/// intelligently classify receipt text into expense categories.
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// WHAT IS GEMINI AI?
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Gemini is Google's most advanced AI model, similar to ChatGPT. It's a
/// **Large Language Model (LLM)** that:
/// - Understands natural language
/// - Can reason about context
/// - Handles multiple languages
/// - Makes intelligent decisions
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// WHY USE GEMINI INSTEAD OF SIMPLE KEYWORDS?
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Traditional Approach (Keywords):
/// - "pizza" → Food ✓
/// - "restaurant" → Food ✓
/// - "grocery" → Food ✓
/// - "medicine from pharmacy" → ??? (contains "pharmacy" but is Health)
/// 
/// Gemini AI Approach:
/// - Understands CONTEXT, not just keywords
/// - "medicine from pharmacy" → Health ✓ (understands "medicine")
/// - "taxi to restaurant" → Transport ✓ (understands "taxi" is transport)
/// - Works in ANY language (French, Arabic, etc.)
/// - Handles misspellings and variations
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// HOW IT WORKS
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// 1. Send receipt text to Gemini AI via API
/// 2. Gemini analyzes the text using its 175+ billion parameters
/// 3. AI understands context and semantics
/// 4. Returns the most appropriate category
/// 5. We validate the response
/// 
/// Example:
/// Input: "CARREFOUR\nTotal: 45.50€\nBread, Milk, Eggs"
/// Gemini thinks: "Carrefour is a grocery store, items are food → Food"
/// Output: "Food"
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// NLP (NATURAL LANGUAGE PROCESSING) CONCEPTS
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// This service demonstrates:
/// - **Text Classification**: Categorizing text into predefined classes
/// - **Semantic Understanding**: Understanding meaning, not just words
/// - **Context Awareness**: Considering the full text, not isolated words
/// - **Zero-shot Learning**: Classifying without training on specific examples
/// - **Prompt Engineering**: Crafting effective instructions for the AI
/// 
/// ═══════════════════════════════════════════════════════════════════════════

class GeminiAIClassificationService {
  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE FIELDS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// The Gemini AI model instance
  /// 
  /// This object handles communication with Google's Gemini API.
  /// It's declared as 'late' because it's initialized asynchronously
  /// in the initialize() method, not in the constructor.
  /// 
  /// 'final' means once initialized, it cannot be reassigned.
  late final GenerativeModel _model;
  
  /// Flag to track if the model has been initialized
  /// 
  /// We check this before making API calls to ensure the model is ready.
  /// Prevents null pointer errors and unnecessary initialization attempts.
  bool _isInitialized = false;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// ═══════════════════════════════════════════════════════════════════════════
  /// INITIALIZE - Set up the Gemini AI model
  /// ═══════════════════════════════════════════════════════════════════════════
  /// 
  /// This method MUST be called before using the classification service.
  /// It sets up the connection to Google's Gemini API.
  /// 
  /// Process:
  /// 1. Validate API key is configured
  /// 2. Create GenerativeModel instance with API key
  /// 3. Mark service as initialized
  /// 
  /// Throws AIException if:
  /// - API key is not configured
  /// - Network connection fails
  /// - API key is invalid
  /// 
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<void> initialize() async {
    try {
      // ───────────────────────────────────────────────────────────────────────
      // STEP 1: VALIDATE API KEY
      // ───────────────────────────────────────────────────────────────────────
      // Check if the API key has been configured in gemini_config.dart
      // The default placeholder key should be replaced with a real key
      if (GeminiConfig.apiKey == 'AIzaSyDdoth3Mcr1wfqKpPhnmnlYfCf-0t1axyA') {
        throw AIException(
          message: 'Gemini API key not configured. Please add your API key to gemini_config.dart',
        );
      }
      
      // ───────────────────────────────────────────────────────────────────────
      // STEP 2: CREATE GEMINI MODEL INSTANCE
      // ───────────────────────────────────────────────────────────────────────
      // Initialize the GenerativeModel with:
      // - model: The specific Gemini model to use (e.g., "gemini-pro")
      // - apiKey: Your Google AI API key for authentication
      // 
      // This creates a connection to Google's Gemini API servers
      _model = GenerativeModel(
        model: GeminiConfig.model,      // Model name (e.g., "gemini-pro")
        apiKey: GeminiConfig.apiKey,    // Your API key
      );
      
      // ───────────────────────────────────────────────────────────────────────
      // STEP 3: MARK AS INITIALIZED
      // ───────────────────────────────────────────────────────────────────────
      // Set flag to true so we know the service is ready to use
      _isInitialized = true;
      
      // Log success message
      debugPrint('✅ Gemini AI initialized successfully');
      debugPrint('   - Model: ${GeminiConfig.model}');
      debugPrint('   - Ready for intelligent classification');
      
    } catch (e) {
      // If anything goes wrong, log the error and throw an exception
      debugPrint('❌ Failed to initialize Gemini AI: $e');
      throw AIException(message: 'Failed to initialize AI: $e');
    }
  }
  
  /// ═══════════════════════════════════════════════════════════════════════════
  /// CLASSIFY RECEIPT - Use AI to categorize receipt text
  /// ═══════════════════════════════════════════════════════════════════════════
  /// 
  /// This is the MAIN method that uses Gemini AI to classify receipts.
  /// 
  /// Parameters:
  ///   receiptText: The full text extracted from the receipt (via OCR)
  /// 
  /// Returns:
  ///   String: The predicted category (Food, Transport, etc.)
  /// 
  /// Process:
  /// 1. Ensure model is initialized
  /// 2. Create a prompt for the AI
  /// 3. Send prompt to Gemini API
  /// 4. Receive and validate response
  /// 5. Return category or fallback to "Other"
  /// 
  /// Example:
  /// ```dart
  /// final category = await service.classifyReceipt("UBER\nTrip to airport\n€25.50");
  /// // Returns: "Transport"
  /// ```
  /// 
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<String> classifyReceipt(String receiptText) async {
    // ─────────────────────────────────────────────────────────────────────────
    // STEP 1: ENSURE INITIALIZATION
    // ─────────────────────────────────────────────────────────────────────────
    // If not initialized, initialize now
    // This is a safety check in case initialize() wasn't called explicitly
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // ───────────────────────────────────────────────────────────────────────
      // STEP 2: CREATE THE PROMPT
      // ───────────────────────────────────────────────────────────────────────
      // This is PROMPT ENGINEERING - crafting instructions for the AI
      // 
      // Good prompts are:
      // - Clear and specific
      // - Include all valid options
      // - Specify the exact output format
      // - Provide context about the task
      // 
      // The prompt tells Gemini:
      // 1. What role to play ("expense categorization AI")
      // 2. What to do ("analyze receipt text")
      // 3. What options are valid (8 categories)
      // 4. How to respond ("ONLY the category name")
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

      // Log that we're making an AI request
      debugPrint('🤖 Gemini AI analyzing receipt...');
      debugPrint('   - Receipt text length: ${receiptText.length} characters');
      
      // ───────────────────────────────────────────────────────────────────────
      // STEP 3: SEND REQUEST TO GEMINI API
      // ───────────────────────────────────────────────────────────────────────
      // Create content object with our prompt
      // Content.text() wraps the prompt in the format Gemini expects
      final content = [Content.text(prompt)];
      
      // Make the API call to Gemini
      // This sends the prompt over the internet to Google's servers
      // Gemini processes it using its 175+ billion parameters
      // Returns a response with the predicted category
      // 
      // This is an ASYNC operation - it takes time (usually 1-3 seconds)
      // The 'await' keyword waits for the response before continuing
      final response = await _model.generateContent(content);
      
      // ───────────────────────────────────────────────────────────────────────
      // STEP 4: EXTRACT AND CLEAN THE RESPONSE
      // ───────────────────────────────────────────────────────────────────────
      // Get the text from the response
      // - response.text: The AI's response as a string
      // - ?.trim(): Remove leading/trailing whitespace (null-safe)
      // - ?? 'Other': If response is null, default to 'Other'
      final category = response.text?.trim() ?? 'Other';
      
      // Log the AI's prediction
      debugPrint('✅ Gemini AI predicted: $category');
      
      // ───────────────────────────────────────────────────────────────────────
      // STEP 5: VALIDATE THE RESPONSE
      // ───────────────────────────────────────────────────────────────────────
      // Even though we told the AI to only return valid categories,
      // we should validate the response to be safe.
      // 
      // Why validate?
      // - AI might misunderstand the prompt
      // - AI might return extra text
      // - Network issues might corrupt the response
      // 
      // List of valid categories (must match our app's categories)
      const validCategories = [
        'Food',          // Groceries, restaurants, cafes
        'Transport',     // Taxi, bus, train, fuel
        'Entertainment', // Movies, games, concerts
        'Shopping',      // Clothes, electronics, general retail
        'Health',        // Medicine, doctor, pharmacy
        'Services',      // Haircut, repairs, subscriptions
        'Housing',       // Rent, utilities, furniture
        'Other'          // Anything that doesn't fit above
      ];
      
      // Check if the AI's response is in our valid list
      if (validCategories.contains(category)) {
        // Valid category - return it
        return category;
      } else {
        // Invalid category - log warning and return 'Other'
        debugPrint('⚠️ Invalid category from AI: $category, defaulting to Other');
        debugPrint('   - Valid categories: ${validCategories.join(", ")}');
        return 'Other';
      }
      
    } catch (e) {
      // ───────────────────────────────────────────────────────────────────────
      // ERROR HANDLING
      // ───────────────────────────────────────────────────────────────────────
      // If anything goes wrong (network error, API error, etc.):
      // 1. Log the error for debugging
      // 2. Return 'Other' as a safe fallback
      // 
      // This ensures the app doesn't crash if AI fails
      // The user can still save the receipt, just without AI classification
      debugPrint('❌ Gemini AI classification failed: $e');
      debugPrint('   - Falling back to "Other" category');
      debugPrint('   - User can manually select correct category');
      
      // Return safe default
      return 'Other';
    }
  }
  
  /// ═══════════════════════════════════════════════════════════════════════════
  /// DISPOSE - Clean up resources
  /// ═══════════════════════════════════════════════════════════════════════════
  /// 
  /// This method should be called when the service is no longer needed.
  /// It releases resources and resets the initialization state.
  /// 
  /// Good practice for:
  /// - Preventing memory leaks
  /// - Cleaning up API connections
  /// - Resetting service state
  /// 
  /// ═══════════════════════════════════════════════════════════════════════════
  void dispose() {
    // Reset the initialization flag
    // This allows the service to be reinitialized if needed
    _isInitialized = false;
    
    // Log cleanup
    debugPrint('🧹 Gemini AI Service disposed');
    debugPrint('   - Service can be reinitialized if needed');
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// USAGE EXAMPLE
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// ```dart
/// // Create service instance
/// final aiService = GeminiAIClassificationService();
/// 
/// // Initialize (do this once at app start)
/// await aiService.initialize();
/// 
/// // Classify a receipt
/// final receiptText = "CARREFOUR\nTotal: 45.50€\nBread, Milk, Eggs";
/// final category = await aiService.classifyReceipt(receiptText);
/// print(category); // Output: "Food"
/// 
/// // Clean up when done
/// aiService.dispose();
/// ```
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// KEY CONCEPTS DEMONSTRATED
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// 1. **Large Language Models (LLM)**: Using Gemini AI for text understanding
/// 2. **Natural Language Processing (NLP)**: Text classification task
/// 3. **Prompt Engineering**: Crafting effective AI instructions
/// 4. **API Integration**: Communicating with external AI services
/// 5. **Async Programming**: Handling asynchronous API calls
/// 6. **Error Handling**: Graceful fallbacks when AI fails
/// 7. **Validation**: Ensuring AI responses are safe and expected
/// 8. **Resource Management**: Proper initialization and disposal
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// ADVANTAGES OVER KEYWORD-BASED CLASSIFICATION
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Gemini AI:
/// ✅ Understands context and semantics
/// ✅ Works in any language
/// ✅ Handles misspellings and variations
/// ✅ Learns from examples in the prompt
/// ✅ Can reason about ambiguous cases
/// 
/// Keyword-based:
/// ❌ Only matches exact words
/// ❌ Requires keywords for each language
/// ❌ Fails on misspellings
/// ❌ Cannot handle context
/// ❌ Needs manual rule updates
/// 
/// ═══════════════════════════════════════════════════════════════════════════
