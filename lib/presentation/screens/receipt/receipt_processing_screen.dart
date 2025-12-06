import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/ocr_service.dart';
import '../../../core/utils/receipt_parser.dart';
import 'ocr_results_screen.dart';

/// Screen that processes receipt image with OCR
class ReceiptProcessingScreen extends StatefulWidget {
  final File imageFile;

  const ReceiptProcessingScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<ReceiptProcessingScreen> createState() => _ReceiptProcessingScreenState();
}

class _ReceiptProcessingScreenState extends State<ReceiptProcessingScreen> {
  final OCRService _ocrService = OCRService();
  bool _isProcessing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Extract text from image
      final text = await _ocrService.extractText(widget.imageFile);
      
      // Parse receipt data
      final parsedData = ReceiptParser.parse(text);
      
      setState(() {
        _isProcessing = false;
      });

      // Navigate to results screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OCRResultsScreen(
              imageFile: widget.imageFile,
              parsedData: parsedData,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Processing Receipt'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                // Processing state
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Extracting text from receipt...',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a few seconds',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ] else if (_errorMessage != null) ...[
                // Error state
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Processing Failed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _processImage,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
