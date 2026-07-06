import 'dart:convert';
import 'dart:io';

import '../models/book.dart';

/// Detect ebook format by reading the file header (magic bytes).
/// More reliable than trusting the file extension.
class FormatDetector {
  static Future<BookFormat> detectFormat(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return BookFormat.epub;

    final raf = await file.open(mode: FileMode.read);
    try {
      final header = await raf.read(8);
      if (header.length < 4) return BookFormat.epub;

      // PDF: %PDF
      if (header[0] == 0x25 && header[1] == 0x50 &&
          header[2] == 0x44 && header[3] == 0x46) {
        return BookFormat.pdf;
      }

      // ZIP (EPUB): PK\x03\x04
      if (header[0] == 0x50 && header[1] == 0x4B &&
          header[2] == 0x03 && header[3] == 0x04) {
        return BookFormat.epub;
      }

      // MOBI/PRC/AZW: BOOKMOBI or TEXtREAd
      if (header.length >= 8) {
        final text = utf8.decode(header.sublist(0, 8), allowMalformed: true);
        if (text.startsWith('BOOKMOBI') || text.startsWith('TEXtREAd')) {
          return BookFormat.mobi;
        }
      }
    } finally {
      await raf.close();
    }

    return BookFormat.epub;
  }
}
