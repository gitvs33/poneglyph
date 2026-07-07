import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Extracts a page thumbnail from a PDF file via the native platform's
/// built-in PDF renderer (PdfRenderer on Android, CGPDFDocument on iOS).
///
/// This avoids depending on any third-party PDF rendering library and works
/// entirely offline.  PDF files must be accessible on the local filesystem
/// (content:// URIs are not supported).
class PdfThumbnailService {
  static const _channel = MethodChannel('com.poneglyph/pdf_thumbnail');

  /// Render [page] (0-indexed) of the PDF at [filePath] as a PNG thumbnail.
  ///
  /// [maxWidth] and [maxHeight] control the target size in pixels; the native
  /// renderer will scale the page proportionally to fit within these bounds.
  ///
  /// Returns the PNG bytes, or `null` on any failure (file not found,
  /// corrupted PDF, etc.).
  static Future<Uint8List?> getThumbnail({
    required String filePath,
    int page = 0,
    int maxWidth = 300,
    int maxHeight = 400,
  }) async {
    try {
      final result = await _channel.invokeMethod<Uint8List>('getThumbnail', {
        'path': filePath,
        'page': page,
        'width': maxWidth,
        'height': maxHeight,
      });
      return result;
    } catch (_) {
      return null;
    }
  }
}
