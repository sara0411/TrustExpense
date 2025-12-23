import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/receipt_provider.dart';

/// Minimal History Screen - Just a simple list
/// 
/// Shows receipts in a basic list format
/// No filters, no fancy UI - just the essentials
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load receipts when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceiptProvider>().loadReceipts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Receipt History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ReceiptProvider>(
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
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadReceipts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty
          if (provider.receipts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No receipts yet'),
                  SizedBox(height: 8),
                  Text('Scan a receipt to get started'),
                ],
              ),
            );
          }

          // List of receipts - simple ListView
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.receipts.length,
            itemBuilder: (context, index) {
              final receipt = provider.receipts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.receipt, color: Colors.white),
                  ),
                  title: Text(
                    receipt.merchant,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(receipt.category),
                  trailing: Text(
                    '\$${receipt.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
