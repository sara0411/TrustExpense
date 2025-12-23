import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/summary_provider.dart';

/// Minimal Summary Screen - Just basic stats
/// 
/// Shows total spending and simple list of categories
/// No charts, no fancy UI - just the numbers
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SummaryProvider>(
        builder: (context, provider, child) {
          // Loading
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          // Error
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Error loading summary'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // No data
          if (!provider.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No receipts this month'),
                ],
              ),
            );
          }

          final summary = provider.currentSummary!;

          // Debug logging
          debugPrint('📊 Summary Debug Info:');
          debugPrint('   Total Amount: \$${summary.totalAmount}');
          debugPrint('   Receipt Count: ${summary.receiptCount}');
          debugPrint('   Categories: ${summary.categoryBreakdown.keys.join(", ")}');
          summary.categoryBreakdown.forEach((category, amount) {
            debugPrint('   - $category: \$${amount.toStringAsFixed(2)}');
          });

          // Simple summary display
          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Spent',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary.formattedTotal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${summary.receiptCount} receipts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Category breakdown title
                  const Text(
                    'By Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Category list - simple cards
                  ...summary.categoryBreakdown.entries.map((entry) {
                    final percentage = summary.getCategoryPercentage(entry.key);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.category, color: Colors.white, size: 20),
                        ),
                        title: Text(entry.key),
                        subtitle: Text('$percentage%'),
                        trailing: Text(
                          '\$${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
