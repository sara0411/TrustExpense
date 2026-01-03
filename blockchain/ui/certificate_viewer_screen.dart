/// Certificate Viewer Screen
/// 
/// Displays blockchain certificate details for a receipt
/// Shows QR code, transaction hash, and verification status
/// 
/// COPY TO: lib/presentation/screens/certificate/certificate_viewer_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// Import your models and services
// import '../../../data/models/receipt.dart';
// import '../../../data/models/certificate.dart';
// import '../../../data/services/certificate_service.dart';
// import '../../../core/constants/blockchain_constants.dart';

class CertificateViewerScreen extends StatelessWidget {
  final dynamic receipt; // Replace with Receipt type
  final CertificateService _certificateService = CertificateService();
  
  CertificateViewerScreen({
    Key? key,
    required this.receipt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Certificate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCertificate(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Badge
            _buildStatusBadge(),
            
            const SizedBox(height: 24),
            
            // QR Code
            _buildQRCodeSection(),
            
            const SizedBox(height: 24),
            
            // Certificate Details
            _buildDetailsSection(),
            
            const SizedBox(height: 24),
            
            // Blockchain Explorer Button
            _buildExplorerButton(context),
            
            const SizedBox(height: 16),
            
            // Verify Button
            _buildVerifyButton(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge() {
    final status = receipt.certificationStatus ?? 'pending';
    final color = _certificateService.getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(status),
            color: color,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQRCodeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Scan to Verify',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // QR Code (placeholder - replace with actual QR)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: receipt.certificateHash != null
                ? _certificateService.generateQRCode(
                    receipt,
                    size: 200,
                  )
                : const Center(
                    child: Text('No certificate'),
                  ),
            ),
            
            const SizedBox(height: 12),
            const Text(
              'Anyone can scan this QR code to verify authenticity',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Certificate Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow(
              'Certificate Hash',
              receipt.certificateHash != null
                ? _certificateService.truncateHash(receipt.certificateHash!)
                : 'N/A',
              onTap: () => _copyToClipboard(receipt.certificateHash ?? ''),
            ),
            
            const Divider(),
            
            _buildDetailRow(
              'Transaction Hash',
              receipt.blockchainTxHash != null
                ? _certificateService.truncateHash(receipt.blockchainTxHash!)
                : 'Pending...',
              onTap: () => _copyToClipboard(receipt.blockchainTxHash ?? ''),
            ),
            
            const Divider(),
            
            _buildDetailRow(
              'Block Number',
              receipt.blockNumber?.toString() ?? 'Pending...',
            ),
            
            const Divider(),
            
            _buildDetailRow(
              'Network',
              'Polygon Mumbai Testnet',
            ),
            
            const Divider(),
            
            _buildDetailRow(
              'Certified At',
              receipt.certifiedAt != null
                ? _certificateService.formatCertificateDate(receipt.certifiedAt!)
                : 'Not yet certified',
            ),
            
            const Divider(),
            
            _buildDetailRow(
              'Certifier Address',
              receipt.certifierAddress != null
                ? _certificateService.truncateHash(receipt.certifierAddress!)
                : 'N/A',
              onTap: () => _copyToClipboard(receipt.certifierAddress ?? ''),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.copy, size: 16, color: Colors.grey),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExplorerButton(BuildContext context) {
    if (receipt.blockchainTxHash == null) {
      return const SizedBox.shrink();
    }
    
    return ElevatedButton.icon(
      onPressed: () => _openBlockExplorer(),
      icon: const Icon(Icons.open_in_new),
      label: const Text('View on PolygonScan'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
  
  Widget _buildVerifyButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _verifyOnBlockchain(context),
      icon: const Icon(Icons.verified_user),
      label: const Text('Verify on Blockchain'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
      case 'submitted':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Show snackbar (implement with your context)
  }
  
  void _shareCertificate(BuildContext context) {
    // Implement share functionality
    // Use share_plus package
  }
  
  void _openBlockExplorer() async {
    if (receipt.blockchainTxHash == null) return;
    
    final url = 'https://mumbai.polygonscan.com/tx/${receipt.blockchainTxHash}';
    // Use url_launcher package
    // await launchUrl(Uri.parse(url));
  }
  
  void _verifyOnBlockchain(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Verify using BlockchainService
    // final service = BlockchainService();
    // final result = await service.verifyCertificate(receipt.certificateId);
    
    // Close loading
    Navigator.pop(context);
    
    // Show result dialog
    // showDialog(...);
  }
}
