class AppConstants {
  AppConstants._();

  static const String appName = 'Poneglyph';
  static const String appVersion = '1.0.0';

  // Layout
  static const double gridPadding = 8.0;
  static const double cardRadius = 16.0;
  static const double grid8 = 8.0;
  static const double grid16 = 16.0;
  static const double grid24 = 24.0;
  static const double grid32 = 32.0;

  // Elevation
  static const double elevationLevel0 = 0;
  static const double elevationLevel1 = 1;
  static const double elevationLevel2 = 4;
  static const double elevationLevel3 = 8;

  // Animation
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // Reading
  static const List<String> fontFamilies = [
    'System',
    'Serif',
    'Sans Serif',
    'Dyslexia',
    'Merriweather',
    'Lora',
    'OpenDyslexic',
  ];

  static const List<String> highlightColors = [
    'Yellow',
    'Green',
    'Blue',
    'Pink',
    'Underline',
  ];

  static const List<double> fontSizeRange = [12, 14, 16, 18, 20, 22, 24, 28, 32, 36];
  static const List<double> lineHeightRange = [1.0, 1.2, 1.4, 1.6, 1.8, 2.0];
  static const List<double> paragraphSpacingRange = [0, 4, 8, 12, 16, 20];
  static const List<double> marginRange = [0, 8, 16, 24, 32, 40];

  // Keys
  static const String themeModeKey = 'theme_mode';
  static const String fontSizeKey = 'font_size';
  static const String fontFamilyKey = 'font_family';
  static const String lineHeightKey = 'line_height';
  static const String appLockKey = 'app_lock_enabled';
  static const String biometricLockKey = 'biometric_lock_enabled';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String readingGoalKey = 'reading_goal';
  static const String keepScreenOnKey = 'keep_screen_on';
  static const String autoNightModeKey = 'auto_night_mode';
}
