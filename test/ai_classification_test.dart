import 'package:flutter_test/flutter_test.dart';
import 'package:trust_expense/data/services/ai_classification_service.dart';

/// Test AI classification for different merchant names
void main() {
  test('AI classifies food merchants correctly', () {
    final classifier = AIClassificationService();
    
    expect(classifier.classifyExpense('McDonald\'s'), 'Food');
    expect(classifier.classifyExpense('Starbucks Coffee'), 'Food');
    expect(classifier.classifyExpense('Pizza Hut'), 'Food');
  });
  
  test('AI classifies transport merchants correctly', () {
    final classifier = AIClassificationService();
    
    expect(classifier.classifyExpense('Uber'), 'Transport');
    expect(classifier.classifyExpense('Shell Gas Station'), 'Transport');
    expect(classifier.classifyExpense('Metro Parking'), 'Transport');
  });
  
  test('AI classifies shopping merchants correctly', () {
    final classifier = AIClassificationService();
    
    expect(classifier.classifyExpense('Amazon'), 'Shopping');
    expect(classifier.classifyExpense('Walmart'), 'Shopping');
    expect(classifier.classifyExpense('Target Store'), 'Shopping');
  });
  
  test('AI defaults to Other for unknown merchants', () {
    final classifier = AIClassificationService();
    
    expect(classifier.classifyExpense('Unknown Merchant'), 'Other');
    expect(classifier.classifyExpense('XYZ Corp'), 'Other');
  });
}
