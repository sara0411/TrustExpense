/// Receipt Card Widget with Blockchain Badge
/// 
/// Enhanced receipt card that shows blockchain certification status
/// Add this to your existing receipt card widget
/// 
/// INTEGRATION: Add to lib/presentation/widgets/receipt_card.dart

import 'package:flutter/material.dart';

// Import your models
// import '../../data/models/receipt.dart';

/// Add this method to your ReceiptCard widget class
Widget buildCertificationBadge(dynamic receipt) {
  final status = receipt.certificationStatus;
  
  if (status == null) {
    return const SizedBox.shrink();
  }
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _getBadgeColor(status).withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _getBadgeColor(status),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getBadgeIcon(status),
          size: 14,
          color: _getBadgeColor(status),
        ),
        const SizedBox(width: 4),
        Text(
          _getBadgeText(status),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _getBadgeColor(status),
          ),
        ),
      ],
    ),
  );
}

Color _getBadgeColor(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return Colors.green;
    case 'submitted':
      return Colors.blue;
    case 'pending':
      return Colors.orange;
    case 'failed':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

IconData _getBadgeIcon(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return Icons.verified;
    case 'submitted':
      return Icons.pending;
    case 'pending':
      return Icons.hourglass_empty;
    case 'failed':
      return Icons.error_outline;
    default:
      return Icons.help_outline;
  }
}

String _getBadgeText(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return 'Certified';
    case 'submitted':
      return 'Certifying';
    case 'pending':
      return 'Pending';
    case 'failed':
      return 'Failed';
    default:
      return status;
  }
}

/// Example of how to integrate into your existing ReceiptCard
class EnhancedReceiptCard extends StatelessWidget {
  final dynamic receipt; // Replace with Receipt type
  
  const EnhancedReceiptCard({
    Key? key,
    required this.receipt,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to receipt details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with merchant and badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      receipt.merchant,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Blockchain certification badge
                  buildCertificationBadge(receipt),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Amount
              Text(
                '\$${receipt.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Category and Date
              Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    receipt.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(receipt.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              // Show blockchain info if certified
              if (receipt.isCertified) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Blockchain certified',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to certificate viewer
                          // Navigator.push(context, MaterialPageRoute(
                          //   builder: (_) => CertificateViewerScreen(receipt: receipt),
                          // ));
                        },
                        child: const Text(
                          'View',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
