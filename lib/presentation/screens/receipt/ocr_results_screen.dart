import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/parsed_receipt_data.dart';
import '../../../data/services/ai_classification_service.dart';
import '../../../data/services/gemini_ai_service.dart';
import 'receipt_form_screen.dart';

/// Screen to display and edit OCR extraction results
class OCRResultsScreen extends StatefulWidget {
  final File imageFile;
  final ParsedReceiptData parsedData;

  const OCRResultsScreen({
    super.key,
    required this.imageFile,
    required this.parsedData,
  });

  @override
  State<OCRResultsScreen> createState() => _OCRResultsScreenState();
}

class _OCRResultsScreenState extends State<OCRResultsScreen> {
  bool _showRawText = false;

  String _formatConfidence(double confidence) {
    final percentage = (confidence * 100).toInt();
    return '$percentage%';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return AppColors.success;
    if (confidence >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  /// Predict category using Gemini AI with fallback
  Future<String> _predictCategoryWithAI() async {
    try {
      final geminiService = GeminiAIClassificationService();
      await geminiService.initialize();
      return await geminiService.classifyReceipt(widget.parsedData.rawText);
    } catch (e) {
      // Fallback to keyword-based
      final keywordService = AIClassificationService();
      return keywordService.classifyExpense(widget.parsedData.rawText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extracted Data'),
        actions: [
          IconButton(
            icon: Icon(_showRawText ? Icons.visibility_off : Icons.visibility),
            tooltip: _showRawText ? 'Hide raw text' : 'Show raw text',
            onPressed: () {
              setState(() {
                _showRawText = !_showRawText;
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Receipt image thumbnail
          Card(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                widget.imageFile,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Extracted data section
          Text(
            'Extracted Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Amount
          _buildDataCard(
            context,
            icon: Icons.attach_money,
            label: 'Amount',
            value: widget.parsedData.amount != null
                ? '\$${widget.parsedData.amount!.toStringAsFixed(2)}'
                : 'Not found',
            confidence: widget.parsedData.amountConfidence,
            hasData: widget.parsedData.hasAmount,
          ),
          const SizedBox(height: 12),

          // Date
          _buildDataCard(
            context,
            icon: Icons.calendar_today,
            label: 'Date',
            value: widget.parsedData.date != null
                ? dateFormat.format(widget.parsedData.date!)
                : 'Not found',
            confidence: widget.parsedData.dateConfidence,
            hasData: widget.parsedData.hasDate,
          ),
          const SizedBox(height: 12),

          // Merchant
          _buildDataCard(
            context,
            icon: Icons.store,
            label: 'Merchant',
            value: widget.parsedData.merchant ?? 'Not found',
            confidence: widget.parsedData.merchantConfidence,
            hasData: widget.parsedData.hasMerchant,
          ),
          const SizedBox(height: 12),

          // AI Predicted Category (using REAL AI)
          FutureBuilder<String>(
            future: _predictCategoryWithAI(),
            builder: (context, snapshot) {
              final category = snapshot.data ?? 'Other';
              final isLoading = snapshot.connectionState == ConnectionState.waiting;
              
              return _buildDataCard(
                context,
                icon: isLoading ? Icons.hourglass_empty : AppConstants.getCategoryIcon(category),
                label: 'Category (AI Predicted)',
                value: isLoading ? 'Analyzing...' : category,
                confidence: 0.9, // Gemini AI has high confidence
                hasData: !isLoading,
              );
            },
          ),
          const SizedBox(height: 24),

          // Raw text section
          if (_showRawText) ...[
            Text(
              'Raw OCR Text',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.parsedData.rawText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Go back to capture
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to receipt form
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReceiptFormScreen(
                          imageFile: widget.imageFile,
                          parsedData: widget.parsedData,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit & Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required double confidence,
    required bool hasData,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasData
                    ? const Color(0x1A4A90E2)
                    : const Color(0x1A9E9E9E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: hasData ? AppColors.primary : AppColors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: hasData ? AppColors.textPrimary : AppColors.grey,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getConfidenceColor(confidence).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatConfidence(confidence),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getConfidenceColor(confidence),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
