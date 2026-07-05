import 'dart:io';

/// Provides the application documents directory without relying on
/// the path_provider plugin (avoids JNI transitive dependency on Linux).
class AppPaths {
  /// Returns the application documents directory path.
  /// On Android this would normally use path_provider; on Linux/desktop we
  /// use the standard XDG data directory via dart:io.
  static Future<Directory> get documentsDir async {
    // Use HOME-based directory for cross-platform compatibility
    // without needing native plugins (path_provider → jni).
    final home = Platform.environment['HOME'] ?? '/tmp';
    final dir = Directory('$home/.local/share/poneglyph');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
