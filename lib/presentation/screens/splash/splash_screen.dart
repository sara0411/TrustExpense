import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../main_scaffold.dart';

/// Splash Screen with Authentication Check
/// 
/// Checks if user is logged in and navigates accordingly:
/// - If logged in → MainScaffold (home screen)
/// - If not logged in → LoginScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  /// Check authentication status and navigate
  Future<void> _checkAuthAndNavigate() async {
    // Wait 1 second to show splash screen
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Get authentication provider
    final authProvider = context.read<AuthProvider>();
    
    // Check if user is authenticated
    final isAuthenticated = authProvider.isAuthenticated;

    // Navigate based on auth status
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isAuthenticated 
              ? const MainScaffold()  // User is logged in
              : const LoginScreen(),  // User needs to log in
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Icon(
              Icons.receipt_long,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            
            // App name
            Text(
              'TrustExpense',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            
            // Loading indicator
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
