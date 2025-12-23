import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme_new.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/supabase_constants.dart';
import 'data/services/auth_service.dart';
import 'data/services/supabase_service.dart';
import 'data/services/storage_service.dart';
import 'data/repositories/receipt_repository.dart';
import 'data/repositories/summary_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/receipt_provider.dart';
import 'presentation/providers/summary_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

/// TrustExpense Main Application Widget
/// 
/// This is the root widget of the entire application. It sets up:
/// 1. State Management (Provider pattern)
/// 2. Dependency Injection (Services and Repositories)
/// 3. App Theme
/// 4. Initial Route (Splash Screen)
/// 
/// Architecture Pattern:
/// - Presentation Layer: Screens and Widgets (UI)
/// - Business Logic Layer: Providers (State Management)
/// - Data Layer: Repositories (Data Access)
/// - Service Layer: External integrations (Supabase, OCR, AI)
class TrustExpenseApp extends StatelessWidget {
  const TrustExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider sets up all state management providers
    // This makes providers available to all widgets in the app via context
    return MultiProvider(
      providers: [
        // Authentication Provider
        // Manages user login/logout state and authentication flow
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
        ),
        
        // Receipt Provider
        // Manages receipt CRUD operations and receipt list state
        // Dependencies: SupabaseService (database), StorageService (images)
        ChangeNotifierProvider(
          create: (_) => ReceiptProvider(
            ReceiptRepository(
              SupabaseService(),  // Database operations
              StorageService(),   // Image storage
            ),
          ),
        ),
        
        // Summary Provider
        // Manages monthly summaries and spending statistics
        // Dependencies: SupabaseService (database queries)
        ChangeNotifierProvider(
          create: (_) => SummaryProvider(
            SummaryRepository(SupabaseService()),
          ),
        ),
      ],
      
      // MaterialApp is the root of the Flutter widget tree
      child: MaterialApp(
        title: AppConstants.appName,           // App name for task switcher
        theme: AppThemeNew.lightTheme,         // App-wide theme (colors, fonts, etc.)
        debugShowCheckedModeBanner: false,     // Hide debug banner in top-right
        home: const SplashScreen(),            // First screen shown on app launch
      ),
    );
  }
}

/// Initialize Supabase Backend and Prepare App for Launch
/// 
/// This function must be called before runApp() in main.dart.
/// It performs essential initialization:
/// 
/// 1. Initializes Flutter bindings (required for async operations before runApp)
/// 2. Connects to Supabase backend (PostgreSQL database + Storage + Auth)
/// 
/// Supabase Setup:
/// - URL: Your Supabase project URL (from supabase_constants.dart)
/// - Anon Key: Public API key for client-side access
/// - This establishes the connection to your cloud database
/// 
/// Error Handling:
/// - If Supabase initialization fails, the app will still run but database
///   operations will fail. This allows development without backend setup.
Future<void> initializeApp() async {
  // Ensure Flutter framework is initialized before any async operations
  // This is required when calling async code before runApp()
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase client with project credentials
    // This connects to your PostgreSQL database, Storage, and Auth services
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,         // Your Supabase project URL
      anonKey: SupabaseConstants.supabaseAnonKey, // Public API key
    );
    
    // Log success message for debugging
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    // If initialization fails (e.g., wrong credentials, no internet)
    // Log the error but don't crash the app
    debugPrint('❌ Supabase initialization error: $e');
    debugPrint('Please update supabase_constants.dart with your project URL and anon key');
    
    // Note: App will continue to run, but database operations will fail
    // This allows UI development without backend setup
  }
}
