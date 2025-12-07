import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/receipt_card.dart';
import '../../widgets/filter_bar.dart';
import '../receipt/receipt_capture_screen.dart';

/// History screen - shows all receipts
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

  Future<void> _onRefresh() async {
    await context.read<ReceiptProvider>().loadReceipts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt History'),
      ),
      body: Consumer<ReceiptProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading && provider.receipts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading receipts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadReceipts(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (provider.receipts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No receipts yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button below\nto add your first receipt',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Receipt list with filters
          final filteredReceipts = provider.filteredReceipts;

          return Column(
            children: [
              // Filter bar
              FilterBar(
                selectedCategory: provider.selectedCategory,
                dateRange: provider.dateRange,
                searchQuery: provider.searchQuery,
                onCategoryChanged: (category) {
                  provider.filterByCategory(category);
                },
                onDateRangeChanged: (dateRange) {
                  provider.filterByDateRange(dateRange);
                },
                onSearchChanged: (query) {
                  provider.searchByMerchant(query);
                },
                onClearFilters: () {
                  provider.clearFilters();
                },
              ),

              // Receipt list
              Expanded(
                child: filteredReceipts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No receipts match your filters',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => provider.clearFilters(),
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredReceipts.length,
                          itemBuilder: (context, index) {
                            final receipt = filteredReceipts[index];
                            return ReceiptCard(
                              receipt: receipt,
                              onTap: () {
                                // TODO: Navigate to detail screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Receipt: ${receipt.merchant}'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to capture screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReceiptCaptureScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
