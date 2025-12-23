import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/parsed_receipt_data.dart';
import '../../../data/services/ai_classification_service.dart';
import '../../../data/services/gemini_ai_service.dart';
import '../../providers/receipt_provider.dart';
import '../../providers/summary_provider.dart';

/// Screen for editing and saving receipt data
class ReceiptFormScreen extends StatefulWidget {
  final File imageFile;
  final ParsedReceiptData parsedData;

  const ReceiptFormScreen({
    super.key,
    required this.imageFile,
    required this.parsedData,
  });

  @override
  State<ReceiptFormScreen> createState() => _ReceiptFormScreenState();
}

class _ReceiptFormScreenState extends State<ReceiptFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  
  // Form values
  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _aiPredictedCategory; // Store the AI prediction separately
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize with parsed data
    _amountController = TextEditingController(
      text: widget.parsedData.amount?.toStringAsFixed(2) ?? '',
    );
    _merchantController = TextEditingController(
      text: widget.parsedData.merchant ?? AppConstants.unknownMerchant,
    );
    _selectedDate = widget.parsedData.date ?? DateTime.now();
    
    // Use REAL AI to predict category from receipt text
    _classifyReceiptWithAI();
  }
  
  /// Classify receipt using Gemini AI with keyword-based fallback
  Future<void> _classifyReceiptWithAI() async {
    final ocrText = widget.parsedData.rawText;
    
    try {
      // Try Gemini AI first (REAL AI)
      final geminiService = GeminiAIClassificationService();
      await geminiService.initialize();
      
      debugPrint('🤖 Using Gemini AI for classification...');
      final aiCategory = await geminiService.classifyReceipt(ocrText);
      
      setState(() {
        _aiPredictedCategory = aiCategory;
        _selectedCategory = _aiPredictedCategory;
      });
      
      debugPrint('✅ Gemini AI predicted: $_aiPredictedCategory');
      
    } catch (e) {
      // Fallback to keyword-based classification if AI fails
      debugPrint('⚠️ Gemini AI failed, using keyword fallback: $e');
      
      final keywordService = AIClassificationService();
      final keywordCategory = keywordService.classifyExpense(ocrText);
      
      setState(() {
        _aiPredictedCategory = keywordCategory;
        _selectedCategory = _aiPredictedCategory;
      });
      
      debugPrint('📝 Keyword-based predicted: $_aiPredictedCategory');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReceipt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final receiptProvider = context.read<ReceiptProvider>();
      
      debugPrint('💾 Saving Receipt:');
      debugPrint('   Amount: \$${_amountController.text}');
      debugPrint('   Merchant: ${_merchantController.text.trim()}');
      debugPrint('   Category: $_selectedCategory');
      debugPrint('   Date: $_selectedDate');
      
      await receiptProvider.createReceipt(
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        merchant: _merchantController.text.trim(),
        category: _selectedCategory,
        categoryConfidence: widget.parsedData.hasAmount ? 0.8 : 0.5,
        manualOverride: true, // User has reviewed/edited
        ocrText: widget.parsedData.rawText,
        imageFile: widget.imageFile,
      );

      if (mounted) {
        // Refresh summary to show the new receipt
        final summaryProvider = context.read<SummaryProvider>();
        await summaryProvider.refresh();
        
        debugPrint('✅ Receipt saved and summary refreshed!');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt saved successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save receipt: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Receipt'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Receipt image thumbnail
            Card(
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                widget.imageFile,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // Form title
            Text(
              'Receipt Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Amount field
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount *',
                prefixText: '\$',
                hintText: '0.00',
                suffixIcon: widget.parsedData.hasAmount
                    ? Icon(Icons.check_circle, color: AppColors.success)
                    : Icon(Icons.edit, color: AppColors.warning),
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Please enter a valid number';
                }
                if (amount < AppConstants.minAmount) {
                  return 'Amount must be at least \$${AppConstants.minAmount}';
                }
                if (amount > AppConstants.maxAmount) {
                  return 'Amount cannot exceed \$${AppConstants.maxAmount}';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date field
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date *',
                  suffixIcon: widget.parsedData.hasDate
                      ? Icon(Icons.check_circle, color: AppColors.success)
                      : Icon(Icons.edit, color: AppColors.warning),
                  border: const OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(_selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Merchant field
            TextFormField(
              controller: _merchantController,
              decoration: InputDecoration(
                labelText: 'Merchant *',
                hintText: 'Store name',
                suffixIcon: widget.parsedData.hasMerchant
                    ? Icon(Icons.check_circle, color: AppColors.success)
                    : Icon(Icons.edit, color: AppColors.warning),
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a merchant name';
                }
                if (value.trim().length < AppConstants.minMerchantNameLength) {
                  return 'Merchant name must be at least ${AppConstants.minMerchantNameLength} characters';
                }
                if (value.trim().length > AppConstants.maxMerchantNameLength) {
                  return 'Merchant name cannot exceed ${AppConstants.maxMerchantNameLength} characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category *',
                helperText: '🤖 AI suggested: $_aiPredictedCategory',
                helperStyle: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                border: const OutlineInputBorder(),
              ),
              items: AppConstants.expenseCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category)),
                      const SizedBox(width: 12),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Info card
            if (!widget.parsedData.isComplete)
              Card(
                color: AppColors.warning.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Some fields were not detected automatically. Please review and correct.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveReceipt,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Save Receipt'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final iconName = AppConstants.categoryIcons[category] ?? 'category';
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'movie':
        return Icons.movie;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'build':
        return Icons.build;
      case 'home':
        return Icons.home;
      default:
        return Icons.category;
    }
  }
}
