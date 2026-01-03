/// Certificate Verification Screen
/// 
/// Allows users to scan QR codes and verify receipt certificates
/// Shows verification results from blockchain
/// 
/// COPY TO: lib/presentation/screens/certificate/certificate_verification_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';

// Import your services
// import '../../../data/services/blockchain_service.dart';
// import '../../../data/services/certificate_service.dart';

class CertificateVerificationScreen extends StatefulWidget {
  const CertificateVerificationScreen({Key? key}) : super(key: key);

  @override
  State<CertificateVerificationScreen> createState() =>
      _CertificateVerificationScreenState();
}

class _CertificateVerificationScreenState
    extends State<CertificateVerificationScreen> {
  final CertificateService _certificateService = CertificateService();
  final BlockchainService _blockchainService = BlockchainService();

  bool _isVerifying = false;
  Map<String, dynamic>? _verificationResult;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Certificate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            _buildInstructions(),

            const SizedBox(height: 24),

            // Scan QR Button
            _buildScanButton(),

            const SizedBox(height: 24),

            // Manual Input Option
            _buildManualInput(),

            const SizedBox(height: 24),

            // Verification Result
            if (_verificationResult != null) _buildVerificationResult(),

            // Error Message
            if (_errorMessage != null) _buildErrorMessage(),

            // Loading Indicator
            if (_isVerifying) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'How to Verify',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Scan the QR code on a receipt certificate\n'
              '2. Or enter the certificate ID manually\n'
              '3. We\'ll verify it on the blockchain',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return ElevatedButton.icon(
      onPressed: _scanQRCode,
      icon: const Icon(Icons.qr_code_scanner, size: 32),
      label: const Text(
        'Scan QR Code',
        style: TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }

  Widget _buildManualInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Or enter certificate ID manually:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '0x1234...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                onSubmitted: (value) => _verifyManual(value),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                // Get text field value and verify
              },
              icon: const Icon(Icons.search),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerificationResult() {
    final result = _verificationResult!;
    final isValid = result['isValid'] as bool;

    return Card(
      color: isValid ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.cancel,
                  color: isValid ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isValid
                        ? 'Certificate Verified ✓'
                        : 'Verification Failed ✗',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isValid ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (isValid) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildResultRow('Receipt Hash', result['receiptHash']),
              _buildResultRow('Certifier', result['certifier']),
              _buildResultRow(
                'Certified At',
                _formatTimestamp(result['timestamp']),
              ),
              const SizedBox(height: 12),
              const Text(
                '✓ This certificate is authentic and recorded on Polygon Mumbai blockchain',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'This certificate could not be verified on the blockchain. '
                'It may be invalid or not yet confirmed.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanQRCode() async {
    try {
      // Use qr_code_scanner package or mobile_scanner
      // final result = await Navigator.push(...);
      
      // For now, simulate scanning
      setState(() {
        _errorMessage = 'QR Scanner not implemented yet. Use manual input.';
      });
      
      // When implemented:
      // if (result != null) {
      //   await _verifyQRData(result);
      // }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to scan QR code: $e';
      });
    }
  }

  Future<void> _verifyQRData(String qrData) async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _verificationResult = null;
    });

    try {
      // Parse QR data
      final data = _certificateService.parseQRCode(qrData);
      final certificateId = data['certificate_id'] as String;

      // Verify on blockchain
      await _blockchainService.initialize();
      final result = await _blockchainService.verifyCertificate(certificateId);

      setState(() {
        _verificationResult = {
          'isValid': result.isValid,
          'receiptHash': result.receiptHash,
          'certifier': _certificateService.truncateHash(result.certifierAddress),
          'timestamp': result.timestamp,
        };
        _isVerifying = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed: $e';
        _isVerifying = false;
      });
    }
  }

  Future<void> _verifyManual(String certificateId) async {
    if (certificateId.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a certificate ID';
      });
      return;
    }

    // Verify using the certificate ID
    await _verifyQRData(jsonEncode({
      'certificate_id': certificateId,
    }));
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
