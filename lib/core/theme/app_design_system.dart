import 'package:flutter/material.dart';

/// TrustExpense Design System - Green Palette
class AppDesignSystem {
  // ============================================
  // GREEN COLOR PALETTE (User specified)
  // ============================================
  
  // Primary greens
  static const primary = Color(0xFF40916C);        // Primary green
  static const primaryDark = Color(0xFF2D6A4F);    // Dark green
  static const primaryLight = Color(0xFF52B788);   // Medium green
  
  // Accent greens
  static const accent = Color(0xFF74C69D);         // Light green
  static const accentLight = Color(0xFF95D5B2);    // Lighter green
  
  // Background - Clean whites with green tint
  static const background = Color(0xFFFAFDFB);     // Very light off-white with green tint
  static const surface = Color(0xFFFFFFFF);        // Pure white
  static const surfaceVariant = Color(0xFFD8F3DC); // Mint green
  
  // Text - Using dark greens
  static const textPrimary = Color(0xFF081C15);    // Darkest green
  static const textSecondary = Color(0xFF1B4332);  // Darker green
  static const textTertiary = Color(0xFF2D6A4F);   // Dark green
  static const textOnPrimary = Color(0xFFFFFFFF);  // White
  static const textDisabled = Color(0xFF95D5B2);   // Lighter green
  
  // Status Colors
  static const success = Color(0xFF52B788);        // Medium green
  static const warning = Color(0xFFF59E0B);        // Amber
  static const error = Color(0xFFEF4444);          // Red
  static const info = Color(0xFF40916C);           // Primary green
  
  // Aliases for compatibility
  static const secondary = accent;
  static const secondaryLight = accentLight;
  
  // Simple gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF40916C), Color(0xFF2D6A4F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const accentGradient = LinearGradient(
    colors: [Color(0xFF74C69D), Color(0xFF95D5B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const successGradient = LinearGradient(
    colors: [Color(0xFF52B788), Color(0xFF40916C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const warningGradient = LinearGradient(
    colors: [warning, Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Category Colors - Muted, professional
  static const categoryFood = Color(0xFFFF6B6B);
  static const categoryTransport = Color(0xFF4A90E2);
  static const categoryEntertainment = Color(0xFF9B59B6);
  static const categoryShopping = Color(0xFFE74C3C);
  static const categoryHealth = Color(0xFF2ECC71);
  static const categoryServices = Color(0xFF3498DB);
  static const categoryHousing = Color(0xFFF39C12);
  static const categoryOther = Color(0xFF95A5A6);
  
  // ============================================
  // SPACING SYSTEM (8px grid)
  // ============================================
  
  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const space24 = 24.0;
  static const space32 = 32.0;
  static const space48 = 48.0;
  
  // ============================================
  // BORDER RADIUS - Subtle
  // ============================================
  
  static const radiusSmall = 8.0;
  static const radiusMedium = 12.0;
  static const radiusLarge = 16.0;
  static const radiusXLarge = 20.0;
  static const radiusFull = 9999.0;
  
  // ============================================
  // SHADOWS - Minimal and subtle
  // ============================================
  
  static final shadowSmall = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static final shadowMedium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static final shadowLarge = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  // ============================================
  // ELEVATION LEVELS
  // ============================================
  
  static const elevation0 = 0.0;
  static const elevation1 = 1.0;
  static const elevation2 = 2.0;
  static const elevation4 = 4.0;
  static const elevation8 = 8.0;
  
  // ============================================
  // TYPOGRAPHY - Clean and readable
  // ============================================
  
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: textPrimary,
    height: 1.2,
  );
  
  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: textPrimary,
    height: 1.2,
  );
  
  static const headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );
  
  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );
  
  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );
  
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );
  
  // Money styles - Clean, not overly bold
  static const moneyLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const moneyMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: -0.3,
    height: 1.2,
  );
  
  static const moneySmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.2,
  );
  
  // ============================================
  // ANIMATION DURATIONS
  // ============================================
  
  static const durationFast = Duration(milliseconds: 150);
  static const durationNormal = Duration(milliseconds: 250);
  static const durationSlow = Duration(milliseconds: 400);
  
  // ============================================
  // ICON SIZES
  // ============================================
  
  static const iconSmall = 16.0;
  static const iconMedium = 20.0;
  static const iconLarge = 24.0;
  static const iconXLarge = 32.0;
}
