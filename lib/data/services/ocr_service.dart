import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/errors/exceptions.dart';

/// OCR (Optical Character Recognition) Service
/// 
/// This service handles text extraction from receipt images using Google ML Kit.
/// ML Kit provides on-device text recognition, meaning all processing happens
/// locally on the user's phone without sending data to external servers.
/// 
/// Key Features:
/// - On-device processing (privacy-first)
/// - Supports multiple languages
/// - Recognizes printed and handwritten text
/// - Returns structured text with block information
class OCRService {
  // TextRecognizer is the ML Kit component that performs text detection
  // It uses a neural network trained on millions of text images
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract plain text from a receipt image
  /// 
  /// This is the main method for getting all text from an image as a single string.
  /// The ML Kit model analyzes the image and returns recognized text.
  /// 
  /// Process:
  /// 1. Convert image file to InputImage format
  /// 2. Pass image through ML Kit's text recognition model
  /// 3. Extract and return all recognized text
  /// 
  /// Parameters:
  ///   - imageFile: The receipt image file from camera or gallery
  /// 
  /// Returns:
  ///   String containing all recognized text from the image
  /// 
  /// Throws:
  ///   - OCRException if no text is found or recognition fails
  Future<String> extractText(File imageFile) async {
    try {
      // Create InputImage from file - this is the format ML Kit expects
      final inputImage = InputImage.fromFile(imageFile);
      
      // Process the image through Google's text recognition neural network
      // This happens on-device and typically takes 1-3 seconds
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Check if any text was found in the image
      if (recognizedText.text.isEmpty) {
        throw OCRException(
          message: 'No text found in image. Please try a clearer photo.',
        );
      }

      // Return the extracted text
      return recognizedText.text;
    } catch (e) {
      // If it's already an OCRException, just rethrow it
      if (e is OCRException) {
        rethrow;
      }
      // Otherwise, wrap the error in an OCRException with context
      throw OCRException(
        message: 'Failed to extract text from image: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Extract text with detailed structural information
  /// 
  /// This method returns the full RecognizedText object which includes:
  /// - Text blocks (paragraphs)
  /// - Text lines within each block
  /// - Individual words and their positions
  /// - Bounding boxes for each text element
  /// 
  /// This is useful when you need to:
  /// - Parse specific fields (like total amount, date)
  /// - Understand text layout and structure
  /// - Extract text from specific regions of the receipt
  /// 
  /// Parameters:
  ///   - imageFile: The receipt image file
  /// 
  /// Returns:
  ///   RecognizedText object with full structural information
  /// 
  /// Throws:
  ///   - OCRException if no text is found or recognition fails
  Future<RecognizedText> extractTextDetailed(File imageFile) async {
    try {
      // Create InputImage from the file
      final inputImage = InputImage.fromFile(imageFile);
      
      // Run ML Kit text recognition
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Validate that text was found
      if (recognizedText.text.isEmpty) {
        throw OCRException(
          message: 'No text found in image. Please try a clearer photo.',
        );
      }

      // Return the full RecognizedText object with all details
      return recognizedText;
    } catch (e) {
      if (e is OCRException) {
        rethrow;
      }
      throw OCRException(
        message: 'Failed to extract text from image: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Clean up and release ML Kit resources
  /// 
  /// This should be called when the OCR service is no longer needed.
  /// It releases the TextRecognizer and frees up memory.
  /// 
  /// Important: After calling dispose(), you cannot use this service instance
  /// again. Create a new instance if you need OCR functionality later.
  void dispose() {
    _textRecognizer.close();
  }
}
