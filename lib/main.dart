import 'package:flutter/material.dart';
import 'app.dart';

/// Application Entry Point
/// 
/// This is the first function that runs when the app starts.
/// It performs two critical steps:
/// 
/// 1. Initialize backend services (Supabase)
/// 2. Launch the Flutter app
/// 
/// Execution Flow:
/// main() → initializeApp() → runApp() → TrustExpenseApp widget tree builds
void main() async {
  // Step 1: Initialize Supabase backend
  // This connects to the database and prepares services
  // Must complete before the app starts
  await initializeApp();
  
  // Step 2: Launch the Flutter application
  // This builds the widget tree starting from TrustExpenseApp
  // The app is now running and visible to the user
  runApp(const TrustExpenseApp());
}
