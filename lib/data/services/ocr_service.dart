import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/errors/exceptions.dart';

/// Service for OCR text recognition from images
class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from image file
  Future<String> extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isEmpty) {
        throw OCRException(
          message: 'No text found in image. Please try a clearer photo.',
        );
      }

      return recognizedText.text;
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

  /// Extract text with detailed block information
  Future<RecognizedText> extractTextDetailed(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isEmpty) {
        throw OCRException(
          message: 'No text found in image. Please try a clearer photo.',
        );
      }

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

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}
