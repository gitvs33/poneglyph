import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds all persistent settings.
///
/// **Reading settings** (font, margins, brightness, etc.) were previously
/// scattered across [ReaderProvider]. They now live here — a single seam
/// for persistence. UI components read from this provider; session-only
/// state (current page, bookmarks, search/TOC) stays in ReaderProvider.
///
/// **Debounced persistence:** setters are synchronous (update in-memory cache
/// + notifyListeners). A single debounced flush writes everything to
/// SharedPreferences once, not N times per toggle.
class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  Timer? _flushTimer;
  bool _isDirty = false;

  // ── State fields (in-memory cache) ─────────────────────

  bool _appLockEnabled = false;
  bool _biometricLockEnabled = false;
  bool _onboardingComplete = false;
  int _readingGoalMinutes = 20;
  bool _keepScreenOn = false;
  bool _autoNightMode = false;
  String _nightModeStart = '22:00';
  String _nightModeEnd = '06:00';
  int _readingStreak = 0;
  String _lastActiveDate = '';
  int _orientationLock = 0;
  double _defaultFontSize = 18.0;
  String _defaultFontFamily = 'System';
  bool _highContrast = false;
  bool _dyslexiaFont = false;
  bool _screenReaderEnabled = false;
  double _dynamicTextScale = 1.0;

  // Reading settings (moved from ReaderProvider)
  double _readingFontSize = 18.0;
  String _readingFontFamily = 'System';
  double _readingFontWeight = 0.5;
  double _readingLineHeight = 1.6;
  double _readingParagraphSpacing = 8.0;
  double _readingMargins = 16.0;
  bool _readingJustification = true;
  double _readingLineWidth = 0.85;
  bool _readingHyphenation = false;
  double _readingBrightness = 1.0;

  // ── Getters ────────────────────────────────────────────

  bool get appLockEnabled => _appLockEnabled;
  bool get biometricLockEnabled => _biometricLockEnabled;
  bool get onboardingComplete => _onboardingComplete;
  int get readingGoalMinutes => _readingGoalMinutes;
  bool get keepScreenOn => _keepScreenOn;
  bool get autoNightMode => _autoNightMode;
  String get nightModeStart => _nightModeStart;
  String get nightModeEnd => _nightModeEnd;
  int get readingStreak => _readingStreak;
  String get lastActiveDate => _lastActiveDate;
  int get orientationLock => _orientationLock;
  double get defaultFontSize => _defaultFontSize;
  String get defaultFontFamily => _defaultFontFamily;
  bool get highContrast => _highContrast;
  bool get dyslexiaFont => _dyslexiaFont;
  bool get screenReaderEnabled => _screenReaderEnabled;
  double get dynamicTextScale => _dynamicTextScale;

  // Reading settings getters
  double get readingFontSize => _readingFontSize;
  String get readingFontFamily => _readingFontFamily;
  double get readingFontWeight => _readingFontWeight;
  double get readingLineHeight => _readingLineHeight;
  double get readingParagraphSpacing => _readingParagraphSpacing;
  double get readingMargins => _readingMargins;
  bool get readingJustification => _readingJustification;
  double get readingLineWidth => _readingLineWidth;
  bool get readingHyphenation => _readingHyphenation;
  double get readingBrightness => _readingBrightness;

  // ── Load (once, at startup) ────────────────────────────

  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;

    _appLockEnabled = p.getBool('app_lock_enabled') ?? false;
    _biometricLockEnabled = p.getBool('biometric_lock_enabled') ?? false;
    _onboardingComplete = p.getBool('onboarding_complete') ?? false;
    _readingGoalMinutes = p.getInt('reading_goal') ?? 20;
    _keepScreenOn = p.getBool('keep_screen_on') ?? false;
    _autoNightMode = p.getBool('auto_night_mode') ?? false;
    _nightModeStart = p.getString('night_mode_start') ?? '22:00';
    _nightModeEnd = p.getString('night_mode_end') ?? '06:00';
    _readingStreak = p.getInt('reading_streak') ?? 0;
    _lastActiveDate = p.getString('last_active_date') ?? '';
    _orientationLock = p.getInt('orientation_lock') ?? 0;
    _defaultFontSize = p.getDouble('default_font_size') ?? 18.0;
    _defaultFontFamily = p.getString('default_font_family') ?? 'System';
    _highContrast = p.getBool('high_contrast') ?? false;
    _dyslexiaFont = p.getBool('dyslexia_font') ?? false;
    _screenReaderEnabled = p.getBool('screen_reader') ?? false;
    _dynamicTextScale = p.getDouble('dynamic_text_scale') ?? 1.0;

    _readingFontSize = p.getDouble('reading_font_size') ?? 18.0;
    _readingFontFamily = p.getString('reading_font_family') ?? 'System';
    _readingFontWeight = p.getDouble('reading_font_weight') ?? 0.5;
    _readingLineHeight = p.getDouble('reading_line_height') ?? 1.6;
    _readingParagraphSpacing = p.getDouble('reading_paragraph_spacing') ?? 8.0;
    _readingMargins = p.getDouble('reading_margins') ?? 16.0;
    _readingJustification = p.getBool('reading_justification') ?? true;
    _readingLineWidth = p.getDouble('reading_line_width') ?? 0.85;
    _readingHyphenation = p.getBool('reading_hyphenation') ?? false;
    _readingBrightness = p.getDouble('reading_brightness') ?? 1.0;

    notifyListeners();
  }

  // ── Setters (synchronous, debounced flush) ─────────────

  void setAppLockEnabled(bool value) {
    _appLockEnabled = value;
    _markDirty();
    notifyListeners();
  }

  void setBiometricLockEnabled(bool value) {
    _biometricLockEnabled = value;
    _markDirty();
    notifyListeners();
  }

  void setOnboardingComplete(bool value) {
    _onboardingComplete = value;
    _markDirty();
    notifyListeners();
  }

  void setReadingGoalMinutes(int minutes) {
    _readingGoalMinutes = minutes;
    _markDirty();
    notifyListeners();
  }

  void setKeepScreenOn(bool value) {
    _keepScreenOn = value;
    _markDirty();
    notifyListeners();
  }

  void setAutoNightMode(bool value) {
    _autoNightMode = value;
    _markDirty();
    notifyListeners();
  }

  void setNightModeStart(String value) {
    _nightModeStart = value;
    _markDirty();
    notifyListeners();
  }

  void setNightModeEnd(String value) {
    _nightModeEnd = value;
    _markDirty();
    notifyListeners();
  }

  /// Returns true if current time falls within night mode window.
  bool isNightMode() {
    if (!_autoNightMode) return false;
    final now = DateTime.now();
    final startParts = _nightModeStart.split(':');
    final endParts = _nightModeEnd.split(':');
    final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    final currentMin = now.hour * 60 + now.minute;
    if (startMin <= endMin) {
      // Same-day window, e.g. 06:00-22:00
      return currentMin >= startMin && currentMin < endMin;
    } else {
      // Overnight window, e.g. 22:00-06:00
      return currentMin >= startMin || currentMin < endMin;
    }
  }

  /// Updates reading streak based on last active date.
  /// Call this when a reading session ends.
  void updateReadingStreak() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    if (_lastActiveDate == todayStr) {
      // Already counted today
      return;
    }
    if (_lastActiveDate.isEmpty) {
      // First time
      _readingStreak = 1;
    } else {
      final lastParts = _lastActiveDate.split('-');
      final lastDate = DateTime(int.parse(lastParts[0]), int.parse(lastParts[1]), int.parse(lastParts[2]));
      final diff = today.difference(lastDate).inDays;
      if (diff == 1) {
        _readingStreak++;
      } else if (diff > 1) {
        // Streak broken
        _readingStreak = 1;
      }
      // diff == 0 handled above by todayStr check
    }
    _lastActiveDate = todayStr;
    _markDirty();
    notifyListeners();
  }

  void setOrientationLock(int value) {
    _orientationLock = value;
    _markDirty();
    notifyListeners();
  }

  void setDefaultFontSize(double value) {
    _defaultFontSize = value;
    _markDirty();
    notifyListeners();
  }

  void setDefaultFontFamily(String value) {
    _defaultFontFamily = value;
    _markDirty();
    notifyListeners();
  }

  void setHighContrast(bool value) {
    _highContrast = value;
    _markDirty();
    notifyListeners();
  }

  void setDyslexiaFont(bool value) {
    _dyslexiaFont = value;
    _markDirty();
    notifyListeners();
  }

  void setScreenReaderEnabled(bool value) {
    _screenReaderEnabled = value;
    _markDirty();
    notifyListeners();
  }

  void setDynamicTextScale(double value) {
    _dynamicTextScale = value;
    _markDirty();
    notifyListeners();
  }

  // ── Reading settings setters ───────────────────────────

  void setReadingFontSize(double value) {
    _readingFontSize = value;
    _markDirty();
    notifyListeners();
  }

  void setReadingFontFamily(String value) {
    _readingFontFamily = value;
    _markDirty();
    notifyListeners();
  }

  void setReadingFontWeight(double value) {
    _readingFontWeight = value;
    _markDirty();
    notifyListeners();
  }

  void setReadingLineHeight(double value) {
    _readingLineHeight = value;
    _markDirty();
    notifyListeners();
  }

  void setReadingParagraphSpacing(double value) {
    _readingParagraphSpacing = value;
    _markDirty();
    notifyListeners();
  }

  void setReadingMargins(double value) {
    _readingMargins = value;
    _markDirty();
    notifyListeners();
  }

  void setReadingJustification(bool value) {
    _readingJustification = value;
    _markDirty();
    notifyListeners();
  }

  void setReadingLineWidth(double value) {
    _readingLineWidth = value;
    _markDirty();
    notifyListeners();
  }

  void setReadingHyphenation(bool value) {
    _readingHyphenation = value;
    _markDirty();
    notifyListeners();
  }

  void setReadingBrightness(double value) {
    _readingBrightness = value;
    _markDirty();
    notifyListeners();
  }

  // ── Persistence ────────────────────────────────────────

  void _markDirty() {
    _isDirty = true;
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(milliseconds: 300), _flush);
  }

  Future<void> _flush() async {
    if (!_isDirty || _prefs == null) return;
    _isDirty = false;

    final p = _prefs!;
    await p.setBool('app_lock_enabled', _appLockEnabled);
    await p.setBool('biometric_lock_enabled', _biometricLockEnabled);
    await p.setBool('onboarding_complete', _onboardingComplete);
    await p.setInt('reading_goal', _readingGoalMinutes);
    await p.setBool('keep_screen_on', _keepScreenOn);
    await p.setBool('auto_night_mode', _autoNightMode);
    await p.setString('night_mode_start', _nightModeStart);
    await p.setString('night_mode_end', _nightModeEnd);
    await p.setInt('reading_streak', _readingStreak);
    await p.setString('last_active_date', _lastActiveDate);
    await p.setInt('orientation_lock', _orientationLock);
    await p.setDouble('default_font_size', _defaultFontSize);
    await p.setString('default_font_family', _defaultFontFamily);
    await p.setBool('high_contrast', _highContrast);
    await p.setBool('dyslexia_font', _dyslexiaFont);
    await p.setBool('screen_reader', _screenReaderEnabled);
    await p.setDouble('dynamic_text_scale', _dynamicTextScale);
    await p.setDouble('reading_font_size', _readingFontSize);
    await p.setString('reading_font_family', _readingFontFamily);
    await p.setDouble('reading_font_weight', _readingFontWeight);
    await p.setDouble('reading_line_height', _readingLineHeight);
    await p.setDouble('reading_paragraph_spacing', _readingParagraphSpacing);
    await p.setDouble('reading_margins', _readingMargins);
    await p.setBool('reading_justification', _readingJustification);
    await p.setDouble('reading_line_width', _readingLineWidth);
    await p.setBool('reading_hyphenation', _readingHyphenation);
    await p.setDouble('reading_brightness', _readingBrightness);
  }

  @override
  void dispose() {
    _flushTimer?.cancel();
    _flush();
    super.dispose();
  }
}
