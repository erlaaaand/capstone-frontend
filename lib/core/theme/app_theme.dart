import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_dimensions.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AppTheme {
  // ── Light ─────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          secondary: AppColors.secondary,
          onSecondary: AppColors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.background,

        // ── AppBar ──────────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          titleTextStyle: AppTextStyles.headlineSmall,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),

        // ── Bottom Navigation ────────────────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight.withAlpha(38),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return const IconThemeData(color: AppColors.textHint, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMedium
                  .copyWith(color: AppColors.primary);
            }
            return AppTextStyles.labelMedium;
          }),
        ),

        // ── Elevated Button ──────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            minimumSize: const Size(
              AppDimensions.buttonMinWidth,
              AppDimensions.buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            elevation: 0,
            textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 16),
          ),
        ),

        // ── Outlined Button ──────────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(
              AppDimensions.buttonMinWidth,
              AppDimensions.buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 16),
          ),
        ),

        // ── Text Button ──────────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ── Input / TextField ────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.divider, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        ),

        // ── Card ─────────────────────────────────────────────────────────────
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: AppDimensions.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          margin: EdgeInsets.zero,
        ),

        // ── Chip ──────────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceAlt,
          labelStyle: AppTextStyles.labelMedium,
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm, vertical: AppDimensions.xs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
        ),

        // ── Divider ───────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // ── Text ──────────────────────────────────────────────────────────────
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ),
      );

  // ── Dark ──────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
      error: const Color(0xFFEF9A9A),
      onError: AppColors.darkBackground,
    );

    final darkTextTheme = light.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
      decorationColor: Colors.white70,
    );

    return light.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: darkColorScheme,
      textTheme: darkTextTheme,

      // Override AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Override Card
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      // Override Input Field
      inputDecorationTheme: light.inputDecorationTheme.copyWith(
        fillColor: AppColors.darkSurfaceAlt,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: Colors.white24, width: 1),
        ),
      ),

      // Override Bottom Navigation Bar
      navigationBarTheme: light.navigationBarTheme.copyWith(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryDark.withAlpha(80),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryLight, size: 24);
          }
          return const IconThemeData(color: Colors.white54, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium
                .copyWith(color: AppColors.primaryLight);
          }
          return AppTextStyles.labelMedium.copyWith(color: Colors.white54);
        }),
      ),

      // Override Chip
      chipTheme: light.chipTheme.copyWith(
        backgroundColor: AppColors.darkSurfaceAlt,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: Colors.white),
      ),

      // Override Divider
      dividerTheme: const DividerThemeData(
        color: Colors.white12,
        thickness: 1,
        space: 1,
      ),
    );
  }
}