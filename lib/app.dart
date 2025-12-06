import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/supabase_constants.dart';
import 'data/services/auth_service.dart';
import 'data/services/supabase_service.dart';
import 'data/services/storage_service.dart';
import 'data/repositories/receipt_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/receipt_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

/// Main application widget
class TrustExpenseApp extends StatelessWidget {
  const TrustExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
        ),
        // Receipt Provider
        ChangeNotifierProvider(
          create: (_) => ReceiptProvider(
            ReceiptRepository(
              SupabaseService(),
              StorageService(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

/// Initialize Supabase and run app
Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    // If Supabase initialization fails, show error
    debugPrint('❌ Supabase initialization error: $e');
    debugPrint('Please update supabase_constants.dart with your project URL and anon key');
  }
}
