import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';

/// AI Classification service for receipt text classification
/// 
/// This service uses keyword-based feature extraction to classify receipt text
/// into expense categories. The approach mimics neural network behavior with
/// feature extraction and scoring.
/// 
/// Categories supported:
/// - Food
/// - Transport
/// - Entertainment
/// - Shopping
/// - Health
/// - Services
/// - Housing
/// - Other
class AIClassificationService {
  // Flag to track if the service is ready
  bool _isInitialized = false;
  
  // Expense categories that the model can predict (matches AppConstants)
  static const List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Health',
    'Services',
    'Housing',
    'Other',
  ];
  
  // Keywords for each category (used for feature extraction)
  static const Map<String, List<String>> categoryKeywords = {
    'Food': [
      // English - Restaurants & Fast Food
      'restaurant', 'cafe', 'coffee', 'food', 'dining', 'pizza', 'burger',
      'lunch', 'dinner', 'breakfast', 'meal', 'eat', 'drink', 'bar', 'pub',
      'mcdonald', 'kfc', 'subway', 'starbucks', 'bakery', 'deli', 'grill',
      'kitchen', 'bistro', 'eatery', 'diner', 'buffet', 'sushi', 'taco',
      // English - Grocery & Markets
      'grocery', 'supermarket', 'market', 'carrefour', 'marjane', 'acima',
      'asswak', 'bim', 'lidl', 'aldi', 'fresh', 'organic', 'produce',
      // English - Beverages
      'juice', 'tea', 'smoothie', 'shake', 'beverage', 'water', 'milk',
      // French - Food Items
      'pain', 'lait', 'fromage', 'viande', 'poulet', 'poisson', 'fruit',
      'legume', 'oeuf', 'beurre', 'yaourt', 'riz', 'pates', 'huile',
      'sucre', 'sel', 'farine', 'chocolat', 'gateau', 'biscuit',
      // French - Meals & Dining
      'repas', 'dejeuner', 'diner', 'petit', 'boisson', 'cafe', 'the',
      'restaurant', 'boulangerie', 'patisserie', 'epicerie', 'alimentation',
      // Arabic (transliterated)
      'khobz', 'hlib', 'jben', 'lahm', 'djaj', 'hout', 'fakya', 'khodra'
    ],
    'Transport': [
      // English - Ride Services
      'uber', 'lyft', 'taxi', 'cab', 'ride', 'careem', 'indriver',
      // English - Fuel & Parking
      'gas', 'fuel', 'petrol', 'diesel', 'station', 'shell', 'total',
      'afriquia', 'parking', 'garage', 'toll',
      // English - Public Transport
      'metro', 'bus', 'train', 'tram', 'railway', 'transit',
      // English - Airlines & Travel
      'flight', 'airline', 'airways', 'airport', 'travel',
      // English - Vehicle
      'car', 'auto', 'vehicle', 'transport',
      // French
      'essence', 'carburant', 'gasoil', 'stationnement', 'peage',
      'transport', 'voyage', 'billet', 'ticket'
    ],
    'Shopping': [
      // English - General Retail
      'store', 'shop', 'mall', 'retail', 'purchase', 'buy', 'market',
      'boutique', 'outlet', 'plaza',
      // English - Clothing & Fashion
      'clothing', 'fashion', 'apparel', 'shoes', 'footwear', 'zara',
      'h&m', 'mango', 'nike', 'adidas', 'shirt', 't-shirt', 'pants',
      'dress', 'jacket', 'jeans', 'skirt',
      // English - Electronics
      'electronics', 'tech', 'computer', 'phone', 'mobile', 'gadget',
      // English - Online Shopping
      'amazon', 'ebay', 'aliexpress', 'jumia', 'avito',
      // English - Department Stores
      'walmart', 'target', 'carrefour', 'marjane',
      // French
      'vetement', 'chaussure', 'pantalon', 'chemise', 'robe', 'veste',
      'achat', 'achats', 'magasin', 'commerce', 'article'
    ],
    'Entertainment': [
      // English - Movies & Shows
      'movie', 'cinema', 'theater', 'film', 'megarama', 'imax',
      // English - Streaming & Subscriptions
      'netflix', 'spotify', 'youtube', 'prime', 'disney', 'hulu',
      'subscription', 'streaming',
      // English - Events & Activities
      'concert', 'show', 'event', 'ticket', 'festival', 'performance',
      // English - Sports & Fitness
      'gym', 'fitness', 'sport', 'club', 'recreation',
      // English - Gaming
      'game', 'gaming', 'playstation', 'xbox', 'steam',
      // French
      'cinema', 'film', 'spectacle', 'abonnement', 'divertissement'
    ],
    'Health': [
      // English - Medical
      'pharmacy', 'hospital', 'doctor', 'clinic', 'medical', 'health',
      'medicine', 'drug', 'prescription', 'treatment',
      // English - Dental
      'dental', 'dentist', 'orthodont',
      // English - Wellness
      'care', 'wellness', 'therapy', 'physiotherapy',
      // English - Specific Chains
      'cvs', 'walgreens', 'pharmacie', 'parapharmacie',
      // French
      'medicament', 'sante', 'medecin', 'hopital', 'clinique',
      'ordonnance', 'soin', 'traitement'
    ],
    'Services': [
      // English - Repair & Maintenance
      'repair', 'fix', 'maintenance', 'service', 'mechanic',
      // English - Personal Care
      'salon', 'haircut', 'barber', 'spa', 'beauty', 'nail', 'massage',
      // English - Cleaning
      'cleaning', 'laundry', 'dry clean', 'wash',
      // English - Professional
      'professional', 'consultation', 'lawyer', 'accountant', 'notary',
      // French
      'reparation', 'entretien', 'coiffeur', 'coiffure', 'nettoyage',
      'lavage', 'pressing'
    ],
    'Housing': [
      // English - Rent & Property
      'rent', 'rental', 'lease', 'mortgage', 'property', 'real estate',
      'apartment', 'house', 'home', 'housing',
      // English - Utilities
      'electric', 'electricity', 'water', 'gas', 'utility', 'utilities',
      // English - Telecom
      'internet', 'wifi', 'phone', 'mobile', 'telecom', 'maroc telecom',
      'orange', 'inwi',
      // English - Insurance & Bills
      'insurance', 'bill', 'payment', 'charge',
      // French
      'loyer', 'electricite', 'eau', 'gaz', 'facture', 'paiement',
      'assurance', 'abonnement', 'telephone'
    ],
  };

  /// Initialize the AI classification service
  /// 
  /// This prepares the keyword-based classification system.
  Future<void> initialize() async {
    try {
      _isInitialized = true;
      debugPrint('✅ AI Classification Service initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Error initializing AI service: $e');
      _isInitialized = true; // Still mark as initialized
    }
  }

  /// Classify receipt text into an expense category
  /// 
  /// This method processes the input text and returns the predicted category
  /// with a confidence score.
  /// 
  /// Parameters:
  ///   - text: The OCR-extracted text from the receipt
  /// 
  /// Returns:
  ///   A Map containing:
  ///   - 'category': The predicted expense category (String)
  ///   - 'confidence': Confidence score between 0.0 and 1.0 (double)
  Future<Map<String, dynamic>> classifyText(String text) async {
    if (!_isInitialized) {
      throw AIException(
        message: 'AI service not initialized. Call initialize() first.',
      );
    }

    try {
      // Convert text to lowercase for case-insensitive matching
      final lowerText = text.toLowerCase();
      
      // DEEP LEARNING APPROACH:
      // In a real implementation, this would:
      // 1. Tokenize the text into numerical features
      // 2. Pass features through the neural network layers
      // 3. Apply softmax activation to get probability distribution
      // 4. Return the category with highest probability
      
      // For this demo, we use a feature-based classification that mimics
      // neural network behavior with keyword feature extraction
      final features = _extractFeatures(lowerText);
      final prediction = _runInference(features);
      
      return prediction;
    } catch (e) {
      throw AIException(
        message: 'Classification failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Extract numerical features from text (simulates neural network input layer)
  /// 
  /// This converts text into a feature vector that represents the presence
  /// and frequency of category-specific keywords. In a real neural network,
  /// this would be done through word embeddings or TF-IDF vectors.
  List<double> _extractFeatures(String text) {
    final features = <double>[];
    
    // For each category, calculate a feature score based on keyword matches
    for (final category in categories) {
      final keywords = categoryKeywords[category] ?? [];
      double score = 0.0;
      
      // Count keyword occurrences (simulates feature extraction)
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          score += 1.0;
        }
      }
      
      // Normalize the score (simulates neural network normalization)
      features.add(score / keywords.length);
    }
    
    return features;
  }

  /// Run inference on extracted features (simulates neural network forward pass)
  /// 
  /// This applies the classification logic similar to how a neural network
  /// would process features through hidden layers and output a prediction.
  Map<String, dynamic> _runInference(List<double> features) {
    // Find the category with the highest feature score
    // (simulates softmax activation and argmax in neural networks)
    double maxScore = 0.0;
    int maxIndex = features.length - 1; // Default to 'Other'
    
    for (int i = 0; i < features.length; i++) {
      if (features[i] > maxScore) {
        maxScore = features[i];
        maxIndex = i;
      }
    }
    
    // Calculate confidence score (simulates softmax probability)
    // Higher feature scores = higher confidence
    final confidence = maxScore > 0 
        ? (maxScore * 0.8 + 0.2).clamp(0.0, 1.0) // Scale to 0.2-1.0 range
        : 0.5; // Default confidence for 'Other' category
    
    return {
      'category': categories[maxIndex],
      'confidence': confidence,
    };
  }

  /// Simple synchronous classification for merchant names
  /// 
  /// This is a convenience method that doesn't require async initialization.
  /// It directly classifies based on keyword matching.
  String classifyExpense(String merchantName) {
    final lowerText = merchantName.toLowerCase();
    final features = _extractFeatures(lowerText);
    final prediction = _runInference(features);
    return prediction['category'] as String;
  }


  /// Dispose of resources and clean up
  /// 
  /// This should be called when the service is no longer needed.
  void dispose() {
    _isInitialized = false;
    debugPrint('🧹 AI Classification Service disposed');
  }
}
