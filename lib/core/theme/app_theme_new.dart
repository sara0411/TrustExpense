import 'package:flutter/material.dart';
import 'app_design_system.dart';

/// Updated theme using the new design system
class AppThemeNew {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: AppDesignSystem.primary,
        primaryContainer: AppDesignSystem.primaryLight,
        secondary: AppDesignSystem.secondary,
        secondaryContainer: AppDesignSystem.secondaryLight,
        tertiary: AppDesignSystem.accent,
        surface: AppDesignSystem.surface,
        surfaceContainerHighest: AppDesignSystem.surfaceVariant,
        error: AppDesignSystem.error,
        onPrimary: AppDesignSystem.textOnPrimary,
        onSecondary: AppDesignSystem.textOnPrimary,
        onSurface: AppDesignSystem.textPrimary,
        onError: AppDesignSystem.textOnPrimary,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppDesignSystem.background,
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppDesignSystem.surface,
        foregroundColor: AppDesignSystem.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppDesignSystem.headlineMedium,
        iconTheme: const IconThemeData(
          color: AppDesignSystem.textPrimary,
        ),
      ),
      
      // Card
      cardTheme: const CardThemeData(
        color: AppDesignSystem.surface,
        elevation: AppDesignSystem.elevation2,
        shadowColor: Color(0x14000000), // Black with 8% opacity
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDesignSystem.radiusMedium)),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppDesignSystem.space16,
          vertical: AppDesignSystem.space8,
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDesignSystem.primary,
          foregroundColor: AppDesignSystem.textOnPrimary,
          elevation: AppDesignSystem.elevation2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space24,
            vertical: AppDesignSystem.space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          ),
          textStyle: AppDesignSystem.labelLarge.copyWith(
            color: AppDesignSystem.textOnPrimary,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppDesignSystem.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space16,
            vertical: AppDesignSystem.space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
          ),
          textStyle: AppDesignSystem.labelLarge,
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppDesignSystem.primary,
          side: const BorderSide(
            color: AppDesignSystem.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space24,
            vertical: AppDesignSystem.space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          ),
          textStyle: AppDesignSystem.labelLarge,
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppDesignSystem.primary,
        foregroundColor: AppDesignSystem.textOnPrimary,
        elevation: AppDesignSystem.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDesignSystem.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          borderSide: const BorderSide(
            color: AppDesignSystem.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          borderSide: const BorderSide(
            color: AppDesignSystem.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDesignSystem.space16,
          vertical: AppDesignSystem.space16,
        ),
        labelStyle: AppDesignSystem.bodyMedium,
        hintStyle: AppDesignSystem.bodyMedium.copyWith(
          color: AppDesignSystem.textDisabled,
        ),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppDesignSystem.surfaceVariant,
        selectedColor: AppDesignSystem.primaryLight,
        labelStyle: AppDesignSystem.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignSystem.space12,
          vertical: AppDesignSystem.space8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppDesignSystem.surfaceVariant,
        thickness: 1,
        space: AppDesignSystem.space16,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppDesignSystem.surface,
        selectedItemColor: AppDesignSystem.primary,
        unselectedItemColor: AppDesignSystem.textSecondary,
        selectedLabelStyle: AppDesignSystem.labelMedium,
        unselectedLabelStyle: AppDesignSystem.labelMedium,
        type: BottomNavigationBarType.fixed,
        elevation: AppDesignSystem.elevation8,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppDesignSystem.displayLarge,
        displayMedium: AppDesignSystem.displayMedium,
        headlineLarge: AppDesignSystem.headlineLarge,
        headlineMedium: AppDesignSystem.headlineMedium,
        titleLarge: AppDesignSystem.titleLarge,
        titleMedium: AppDesignSystem.titleMedium,
        bodyLarge: AppDesignSystem.bodyLarge,
        bodyMedium: AppDesignSystem.bodyMedium,
        bodySmall: AppDesignSystem.bodySmall,
        labelLarge: AppDesignSystem.labelLarge,
        labelMedium: AppDesignSystem.labelMedium,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppDesignSystem.textPrimary,
        size: AppDesignSystem.iconMedium,
      ),
    );
  }
}
