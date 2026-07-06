import 'package:flutter/material.dart';
import 'design_tokens.dart';

enum AppThemeMode { light, dark, sepia, amoled, custom }

// Design colors from the JPEG
const kPrimary = Color(0xFF7C6FFF);        // Purple accent
const kDarkBg = Color(0xFF0F0F17);          // Very dark background
const kDarkSurface = Color(0xFF1A1A2E);     // Card surface
const kDarkSurface2 = Color(0xFF16213E);    // Slightly lighter surface
const kDarkText = Color(0xFFEAEAF4);        // Primary text
const kDarkSubtext = Color(0xFF8888A8);     // Secondary text

// Helper: creates a TextStyle with Inter-like sizing
TextStyle _st(double size, FontWeight weight, Color color, {double? letterSpacing}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
  );
}

class AppTheme {
  final AppThemeMode mode;
  final ThemeData data;
  final Color primaryColor;
  final Color surfaceColor;
  final Color backgroundColor;
  final Color textColor;
  final Color? readerBackground;
  final Color? readerText;

  const AppTheme({
    required this.mode,
    required this.data,
    required this.primaryColor,
    required this.surfaceColor,
    required this.backgroundColor,
    required this.textColor,
    this.readerBackground,
    this.readerText,
  });

  static AppTheme fromMode(AppThemeMode mode,
      {Color? customPrimary, Color? customBackground}) {
    switch (mode) {
      case AppThemeMode.light:
        return _buildLight();
      case AppThemeMode.dark:
        return _buildDark();
      case AppThemeMode.sepia:
        return _buildSepia();
      case AppThemeMode.amoled:
        return _buildAMOLED();
      case AppThemeMode.custom:
        return _buildCustom(
          primary: customPrimary ?? kPrimary,
          background: customBackground ?? kDarkBg,
        );
    }
  }

  static AppTheme _base(
    AppThemeMode mode, {
    required Color primary,
    required Color surface,
    required Color background,
    required Color text,
    Brightness brightness = Brightness.light,
    Color? readerBg,
    Color? readerText,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: surface,
    ).copyWith(
      primary: primary,
      surface: surface,
    );

    final theme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      textTheme: ThemeData().textTheme.apply(
        bodyColor: text,
        displayColor: text,
      ).copyWith(
        displayLarge: _st(32, FontWeight.bold, text),
        displayMedium: _st(28, FontWeight.bold, text),
        displaySmall: _st(24, FontWeight.w600, text),
        headlineLarge: _st(22, FontWeight.w600, text),
        headlineMedium: _st(20, FontWeight.w600, text),
        headlineSmall: _st(18, FontWeight.w600, text),
        titleLarge: _st(16, FontWeight.w600, text),
        titleMedium: _st(14, FontWeight.w500, text),
        titleSmall: _st(12, FontWeight.w500, text),
        bodyLarge: _st(16, FontWeight.normal, text),
        bodyMedium: _st(14, FontWeight.normal, text),
        bodySmall: _st(12, FontWeight.normal, text),
        labelLarge: _st(14, FontWeight.w500, text),
        labelMedium: _st(12, FontWeight.w500, text),
        labelSmall: _st(10, FontWeight.w500, text),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        color: surface,
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: primary,
        unselectedItemColor: text.withAlpha(100),
        type: BottomNavigationBarType.fixed,
        backgroundColor: surface,
        selectedLabelStyle: _st(10, FontWeight.w600, primary),
        unselectedLabelStyle: _st(10, FontWeight.w500, text.withAlpha(100)),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _st(17, FontWeight.w600, text),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.grid24, vertical: DesignTokens.grid16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.grid24, vertical: DesignTokens.grid16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.grid16, vertical: DesignTokens.grid12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(DesignTokens.grid16),
        hintStyle: _st(14, FontWeight.normal, text.withAlpha(100)),
      ),
      dividerTheme: DividerThemeData(
        color: text.withAlpha(20),
        thickness: 1,
        space: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primary.withAlpha(25),
        labelStyle: _st(12, FontWeight.w500, primary),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull)),
        side: BorderSide.none,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        overlayColor: primary.withAlpha(30),
        inactiveTrackColor: text.withAlpha(25),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return text.withAlpha(100);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary.withAlpha(60);
          return text.withAlpha(25);
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: text.withAlpha(25),
      ),
    );

    return AppTheme(
      mode: mode,
      data: theme,
      primaryColor: primary,
      surfaceColor: surface,
      backgroundColor: background,
      textColor: text,
      readerBackground: readerBg,
      readerText: readerText,
    );
  }

  static AppTheme _buildLight() => _base(
        AppThemeMode.light,
        primary: kPrimary,
        surface: Colors.white,
        background: const Color(0xFFF5F5FA),
        text: const Color(0xFF1A1A2E),
        readerBg: const Color(0xFFFDFDFD),
        readerText: const Color(0xFF1A1A2E),
      );

  static AppTheme _buildDark() => _base(
        AppThemeMode.dark,
        primary: kPrimary,
        surface: kDarkSurface,
        background: kDarkBg,
        text: kDarkText,
        brightness: Brightness.dark,
        readerBg: kDarkSurface,
        readerText: kDarkText,
      );

  static AppTheme _buildSepia() => _base(
        AppThemeMode.sepia,
        primary: const Color(0xFF8B6914),
        surface: const Color(0xFFF5EDD6),
        background: const Color(0xFFF0E8C8),
        text: const Color(0xFF3B2F1A),
        readerBg: const Color(0xFFF8F0D8),
        readerText: const Color(0xFF3E2C14),
      );

  static AppTheme _buildAMOLED() => _base(
        AppThemeMode.amoled,
        primary: kPrimary,
        surface: const Color(0xFF0A0A0A),
        background: const Color(0xFF000000),
        text: kDarkText,
        brightness: Brightness.dark,
        readerBg: const Color(0xFF000000),
        readerText: const Color(0xFFD0D0D0),
      );

  static AppTheme _buildCustom(
      {required Color primary, required Color background}) {
    final isDark = background.computeLuminance() < 0.5;
    final text = isDark ? kDarkText : const Color(0xFF1A1A2E);
    final surface = isDark ? kDarkSurface : Colors.white;
    return _base(
      AppThemeMode.custom,
      primary: primary,
      surface: surface,
      background: background,
      text: text,
      brightness: isDark ? Brightness.dark : Brightness.light,
      readerBg: surface,
      readerText: text,
    );
  }
}
