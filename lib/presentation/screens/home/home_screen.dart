import 'package:flutter/material.dart';
import '../receipt/receipt_capture_screen.dart';

/// Minimal Home Screen - Just the basics
/// 
/// This is the simplest possible home screen with:
/// - A title
/// - One button to scan receipts
/// - That's it!
class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;
  
  const HomeScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Simple white background
      backgroundColor: Colors.white,
      
      // App bar with title
      appBar: AppBar(
        title: const Text('TrustExpense'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      
      // Main content - centered button
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              const Icon(
                Icons.receipt_long,
                size: 80,
                color: Colors.green,
              ),
              
              const SizedBox(height: 40),
              
              // Main action button - Scan Receipt
              ElevatedButton.icon(
                onPressed: () {
                  // Open camera to scan receipt
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const ReceiptCaptureScreen(),
                  );
                },
                icon: const Icon(Icons.camera_alt, size: 28),
                label: const Text(
                  'Scan Receipt',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Secondary button - View History
              TextButton(
                onPressed: () => onNavigate(1),
                child: const Text(
                  'View History',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Tertiary button - View Summary
              TextButton(
                onPressed: () => onNavigate(2),
                child: const Text(
                  'View Summary',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
