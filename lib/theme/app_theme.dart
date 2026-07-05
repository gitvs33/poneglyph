import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

enum AppThemeMode { light, dark, sepia, amoled, custom }

// Design colors from the JPEG
const kPrimary = Color(0xFF7C6FFF);        // Purple accent
const kDarkBg = Color(0xFF0F0F17);          // Very dark background
const kDarkSurface = Color(0xFF1A1A2E);     // Card surface
const kDarkSurface2 = Color(0xFF16213E);    // Slightly lighter surface
const kDarkText = Color(0xFFEAEAF4);        // Primary text
const kDarkSubtext = Color(0xFF8888A8);     // Secondary text

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
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: text,
        displayColor: text,
      ).copyWith(
        displayLarge: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.bold, color: text),
        displayMedium: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.bold, color: text),
        displaySmall: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w600, color: text),
        headlineLarge: GoogleFonts.inter(
            fontSize: 22, fontWeight: FontWeight.w600, color: text),
        headlineMedium: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w600, color: text),
        headlineSmall: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w600, color: text),
        titleLarge: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600, color: text),
        titleMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: text),
        titleSmall: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500, color: text),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.normal, color: text),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.normal, color: text),
        bodySmall: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.normal, color: text),
        labelLarge: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: text),
        labelMedium: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500, color: text),
        labelSmall: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w500, color: text),
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
        selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: text,
        ),
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
        hintStyle: GoogleFonts.inter(fontSize: 14, color: text.withAlpha(100)),
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
        labelStyle: GoogleFonts.inter(fontSize: 12, color: primary),
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
