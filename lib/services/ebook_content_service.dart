import 'dart:io';
import 'dart:typed_data';

import '../models/book.dart';
import 'epub_parser.dart';
import 'format_detector.dart';
import 'pdf_text_extractor.dart';

/// Characters per "page" used for rough page estimation.
const int kCharsPerPage = 1500;

/// Represents one chapter of an ebook with its plain-text content.
class EbookChapter {
  final String title;
  final String content; // plain text, no HTML
  final int estimatedPages;

  EbookChapter({
    required this.title,
    required this.content,
    this.estimatedPages = 1,
  });
}

/// Full parsed content of an ebook.
class EbookContent {
  final String title;
  final String author;
  final List<EbookChapter> chapters;
  final int totalEstimatedPages;
  final int totalCharacters;
  final Uint8List? coverImageBytes;

  EbookContent({
    required this.title,
    required this.author,
    required this.chapters,
    this.coverImageBytes,
  })  : totalEstimatedPages =
            chapters.fold(0, (sum, c) => sum + c.estimatedPages),
        totalCharacters =
            chapters.fold(0, (sum, c) => sum + c.content.length);
}

/// Service that reads ebook files and extracts plain-text content.
///
/// Thin router: delegates to format-specific parsers.
class EbookContentService {
  /// Read an ebook from [filePath] in the given [format].
  /// Returns null if the format is not supported or the file can't be parsed.
  Future<EbookContent?> readBook(String filePath, BookFormat format) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    // Check actual format by magic bytes BEFORE parsing.
    final actualFormat = await FormatDetector.detectFormat(filePath);
    if (actualFormat != format) {
      format = actualFormat;
    }

    switch (format) {
      case BookFormat.epub:
        return EpubParser.readEpub(file);
      case BookFormat.pdf:
        return PdfTextExtractor.readPdf(file);
      case BookFormat.mobi:
        throw UnsupportedError(
            'MOBI format not yet supported. Convert to EPUB for best results.');
    }
  }
}
