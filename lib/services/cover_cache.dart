import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import 'pdf_thumbnail_service.dart';

/// Lightweight cache for book cover images.
///
/// Extracts cover images from EPUB files (ZIP archive scanning + OPF parsing)
/// and renders the first page of PDF files via the native platform PDF renderer.
/// Cached images are stored as JPEG/PNG files in `{appDocsDir}/covers/`.
class CoverCache {
  /// Extract a cover image from a book file and cache it.
  ///
  /// Returns the path to the cached image file, or `null` if no cover could
  /// be extracted.
  static Future<String?> cacheCover(String bookId, String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;

      Uint8List? coverBytes;

      // Detect file format by magic bytes.
      if (_isPdf(bytes)) {
        coverBytes = await PdfThumbnailService.getThumbnail(
          filePath: filePath,
          page: 0,
          maxWidth: 300,
          maxHeight: 400,
        );
      } else {
        // Assume EPUB (ZIP archive).
        try {
          final archive = ZipDecoder().decodeBytes(bytes);
          coverBytes = _extractEpubCover(archive);
        } catch (_) {
          // Not a valid ZIP — nothing we can do.
        }
      }

      if (coverBytes == null || coverBytes.isEmpty) return null;

      // Persist to covers directory.
      final docsDir = await getApplicationDocumentsDirectory();
      final coversDir = Directory('${docsDir.path}/covers');
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }

      final isPng = _isPng(coverBytes);
      final cachePath = '${coversDir.path}/${bookId}_cover.${isPng ? 'png' : 'jpg'}';
      await File(cachePath).writeAsBytes(coverBytes);
      return cachePath;
    } catch (_) {
      return null;
    }
  }

  /// Delete a cached cover image.
  static Future<void> deleteCover(String? coverUrl) async {
    if (coverUrl == null) return;
    try {
      final file = File(coverUrl);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort.
    }
  }

  /// Check if a cached cover image exists and is valid.
  static Future<bool> hasValidCover(String? coverUrl) async {
    if (coverUrl == null || coverUrl.isEmpty) return false;
    try {
      final file = File(coverUrl);
      return await file.exists() && await file.length() > 0;
    } catch (_) {
      return false;
    }
  }

  // ── Format detection ──────────────────────────────────────

  static bool _isPdf(Uint8List bytes) {
    if (bytes.length < 4) return false;
    // PDF files start with "%PDF"
    return bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46;
  }

  static bool _isPng(Uint8List bytes) {
    if (bytes.length < 8) return false;
    return bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0d &&
        bytes[5] == 0x0a &&
        bytes[6] == 0x1a &&
        bytes[7] == 0x0a;
  }

  // ── EPUB helpers ──────────────────────────────────────────

  /// Try to find and extract the cover image from an EPUB archive.
  static Uint8List? _extractEpubCover(Archive archive) {
    // Priority list of common cover filenames (case-insensitive).
    const coverNames = [
      'cover.jpg',
      'cover.jpeg',
      'cover.png',
      'cover.gif',
      'cover.webp',
      'cover.svg',
      'coverimage.jpg',
      'cover_image.jpg',
      'cover-image.jpg',
      'coverimage.jpeg',
      'cover_image.png',
      'Cover.jpg',
      'Cover.png',
      'cover.JPG',
      'cover.PNG',
    ];

    // 1. Try common filenames first (fast path).
    for (final name in coverNames) {
      for (final entry in archive) {
        final entryName = entry.name;
        if (entryName.endsWith('/$name') || entryName == name) {
          final content = entry.content;
          if (content is Uint8List && content.isNotEmpty) {
            return content;
          }
        }
      }
    }

    // 2. Try OPF manifest: find metadata cover reference.
    try {
      final containerEntry =
          archive.files.firstWhere((e) => e.name == 'META-INF/container.xml',
              orElse: () => archive.files.firstWhere(
                  (e) => e.name.endsWith('container.xml'),
                  orElse: () => archive.files.first));

      if (containerEntry.name.contains('container.xml')) {
        final containerRaw = containerEntry.content;
        if (containerRaw is Uint8List || containerRaw is List<int>) {
          final containerText = String.fromCharCodes(
              containerRaw is Uint8List ? containerRaw : containerRaw as List<int>);

          final opfMatch =
              RegExp(r'full-path="([^"]+)"').firstMatch(containerText);
          if (opfMatch != null) {
            final opfPath = opfMatch.group(1)!;
            final opfDir = opfPath.contains('/')
                ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1)
                : '';

            final opfEntry = _findEntry(archive, opfPath);
            if (opfEntry != null) {
              final opfRaw = opfEntry.content;
              if (opfRaw is Uint8List || opfRaw is List<int>) {
                final opfText = String.fromCharCodes(
                    opfRaw is Uint8List ? opfRaw : opfRaw as List<int>);

                final coverMetaMatch = RegExp(
                        r'<meta\s+name="cover"\s+content="([^"]+)"',
                        caseSensitive: false)
                    .firstMatch(opfText);
                if (coverMetaMatch != null) {
                  final coverId = coverMetaMatch.group(1)!;
                  final itemMatch = RegExp(
                          r'<item\s+[^>]*id="' +
                              RegExp.escape(coverId) +
                              r'"[^>]*href="([^"]+)"',
                          caseSensitive: false)
                      .firstMatch(opfText);
                  if (itemMatch != null) {
                    final href = itemMatch.group(1)!;
                    final imageEntry = _findEntry(archive, '$opfDir$href') ??
                        _findEntry(archive, href);
                    if (imageEntry != null) {
                      final content = imageEntry.content;
                      if (content is Uint8List && content.isNotEmpty) {
                        return content;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  static ArchiveFile? _findEntry(Archive archive, String path) {
    String normalizedPath =
        path.replaceAll('\\', '/').replaceAll('//', '/');
    while (normalizedPath.startsWith('./') || normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.startsWith('./')
          ? normalizedPath.substring(2)
          : normalizedPath.substring(1);
    }

    for (final entry in archive) {
      if (entry.name == normalizedPath) return entry;
    }

    final lower = normalizedPath.toLowerCase();
    for (final entry in archive) {
      if (entry.name.toLowerCase() == lower) return entry;
    }

    final filename = normalizedPath.split('/').last;
    for (final entry in archive) {
      if (entry.name.endsWith('/$filename') ||
          entry.name == filename ||
          entry.name.toLowerCase().endsWith('/${filename.toLowerCase()}')) {
        return entry;
      }
    }

    return null;
  }
}
