import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  // Initialize Firebase
  await initializeApp();
  
  // Run app
  runApp(const TrustExpenseApp());
}
