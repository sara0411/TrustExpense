import 'package:flutter/material.dart';

/// App color palette - Custom green theme
class AppColors {
  // User's specified green palette
  static const darkestGreen = Color(0xFF081C15);  // Darkest
  static const darkerGreen = Color(0xFF1B4332);   // Darker
  static const darkGreen = Color(0xFF2D6A4F);     // Dark
  static const primaryGreen = Color(0xFF40916C);  // Primary
  static const mediumGreen = Color(0xFF52B788);   // Medium
  static const lightGreen = Color(0xFF74C69D);    // Light
  static const lighterGreen = Color(0xFF95D5B2);  // Lighter
  static const lightestGreen = Color(0xFFB7E4C7); // Lightest
  static const mintGreen = Color(0xFFD8F3DC);     // Mint

  // Semantic colors using the green palette
  static const primary = primaryGreen;
  static const primaryLight = mediumGreen;
  static const primaryDark = darkGreen;
  static const secondary = mediumGreen;
  static const accent = lightGreen;
  static const accentDark = darkGreen;
  static const background = Color(0xFFFAFDFB); // Very light off-white with green tint
  static const surface = Colors.white;
  static const white = Colors.white;
  static const black = Colors.black;
  static const grey = Color(0xFF9CA3AF);
  static const greyLight = Color(0xFFF3F4F6);
  static const divider = Color(0xFFE5E7EB);
  
  // Text colors
  static const textPrimary = darkestGreen;
  static const textSecondary = darkerGreen;
  static const textTertiary = darkGreen;
  static const textDisabled = Color(0xFF9CA3AF);
  static const textHint = Color(0xFF9CA3AF);
  
  // Border colors
  static const border = Color(0xFFE5E7EB);
  static const borderFocus = primaryGreen;

  // Status colors using green palette
  static const success = mediumGreen;
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFF59E0B);
  static const info = primaryGreen;

  // Category colors - using neutral gray to avoid color overload
  // Green is reserved for brand elements (hero card, buttons, accents)
  static Color getCategoryColor(String category) {
    // All categories use the same neutral gray
    // This creates visual calm and lets the green brand elements stand out
    return const Color(0xFF6B7280); // Medium gray for all categories
  }
}
