import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Filter bar widget for history screen
class FilterBar extends StatelessWidget {
  final String? selectedCategory;
  final DateTimeRange? dateRange;
  final String? searchQuery;
  final Function(String?) onCategoryChanged;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(String) onSearchChanged;
  final VoidCallback onClearFilters;

  const FilterBar({
    super.key,
    this.selectedCategory,
    this.dateRange,
    this.searchQuery,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
    required this.onSearchChanged,
    required this.onClearFilters,
  });

  bool get hasActiveFilters =>
      selectedCategory != null || dateRange != null || (searchQuery?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by merchant...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery?.isNotEmpty ?? false
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onSearchChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),
          
          // Filter chips row
          Row(
            children: [
              // Category filter
              Expanded(
                child: _buildCategoryChip(context),
              ),
              const SizedBox(width: 8),
              
              // Date range filter
              Expanded(
                child: _buildDateRangeChip(context),
              ),
              
              // Clear filters button
              if (hasActiveFilters) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: onClearFilters,
                  tooltip: 'Clear filters',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    return InkWell(
      onTap: () => _showCategoryPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedCategory != null
                ? AppColors.primary
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: selectedCategory != null
              ? AppColors.primary.withValues(alpha: 0.1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category,
              size: 18,
              color: selectedCategory != null
                  ? AppColors.primary
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedCategory ?? 'Category',
                style: TextStyle(
                  color: selectedCategory != null
                      ? AppColors.primary
                      : Colors.grey.shade600,
                  fontWeight: selectedCategory != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: selectedCategory != null
                  ? AppColors.primary
                  : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeChip(BuildContext context) {
    final dateText = dateRange != null
        ? '${_formatDate(dateRange!.start)} - ${_formatDate(dateRange!.end)}'
        : 'Date range';

    return InkWell(
      onTap: () => _showDateRangePicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: dateRange != null
                ? AppColors.primary
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: dateRange != null
              ? AppColors.primary.withValues(alpha: 0.1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 18,
              color: dateRange != null
                  ? AppColors.primary
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(
                  color: dateRange != null
                      ? AppColors.primary
                      : Colors.grey.shade600,
                  fontWeight: dateRange != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...AppConstants.expenseCategories.map((category) {
              final isSelected = category == selectedCategory;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.primary : null,
                ),
                title: Text(category),
                selected: isSelected,
                onTap: () {
                  onCategoryChanged(category);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear filter'),
              onTap: () {
                onCategoryChanged(null);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
    );
    
    if (picked != null) {
      onDateRangeChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
