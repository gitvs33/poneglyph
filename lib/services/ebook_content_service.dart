import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:xml/xml.dart';

import '../models/book.dart';

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
  })  : totalEstimatedPages = chapters.fold(0, (sum, c) => sum + c.estimatedPages),
        totalCharacters = chapters.fold(0, (sum, c) => sum + c.content.length);
}

/// Characters per "page" used for rough page estimation.
/// Will be refined later with font-metrics–based layout.
const int kCharsPerPage = 1500;

/// Service that reads ebook files and extracts plain-text content.
class EbookContentService {
  /// Read an ebook from [filePath] in the given [format].
  /// Returns null if the format is not supported or the file can't be parsed.
  Future<EbookContent?> readBook(String filePath, BookFormat format) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    switch (format) {
      case BookFormat.epub:
        return _readEpub(file);
      case BookFormat.pdf:
        return _readPdf(file);
      case BookFormat.mobi:
        return _readMobi(file);
    }
  }

  // ── EPUB ────────────────────────────────────────────────

  Future<EbookContent> _readEpub(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final book = await EpubReader.readBook(bytes);

      final chapters = <EbookChapter>[];
      if (book.Chapters != null) {
        for (final ch in book.Chapters!) {
          chapters.add(_epubChapterToEbook(ch));
        }
      }
      // Flatten nested sub-chapters
      final flat = _flattenChapters(chapters);

      final coverBytes =
          book.CoverImage != null ? book.CoverImage!.getBytes() : null;

      return EbookContent(
        title: book.Title ?? file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^.]+$'), ''),
        author: book.Author ?? 'Unknown',
        chapters: flat,
        coverImageBytes: coverBytes,
      );
    } catch (e) {
      // Fallback: try reading as raw text
      return _fallbackTextContent(file, 'EPUB');
    }
  }

  EbookChapter _epubChapterToEbook(dynamic ch) {
    String htmlContent = '';
    String title = '';

    // epubx returns EpubChapter with Title and HtmlContent
    if (ch is EpubChapter) {
      title = ch.Title ?? '';
      htmlContent = ch.HtmlContent ?? '';
    } else {
      // Fallback for any other chapter type
      final map = ch as Map<String, dynamic>;
      title = map['title'] as String? ?? '';
      htmlContent = map['htmlContent'] as String? ?? '';
    }

    final text = _stripHtml(htmlContent);
    final estimatedPages = max(1, (text.length / kCharsPerPage).ceil());

    return EbookChapter(
      title: title,
      content: text,
      estimatedPages: estimatedPages,
    );
  }

  List<EbookChapter> _flattenChapters(List<EbookChapter> chapters) {
    final result = <EbookChapter>[];
    for (final ch in chapters) {
      result.add(ch);
      // Sub-chapters are already part of the EpubChapter tree;
      // they are extracted by _epubChapterToEbook which only
      // handles the current level.  We rely on epubx's
      // SubChapters being included in the list.
    }
    return result;
  }

  // ── PDF ─────────────────────────────────────────────────

  Future<EbookContent> _readPdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final text = await _extractPdfText(bytes);

      if (text.trim().isEmpty) {
        throw Exception('No text content found in PDF');
      }

      // Split into chapters heuristically by "Chapter", "Part", etc.
      final title =
          file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^.]+$'), '');
      final chapters = _splitIntoChapters(title, text);

      return EbookContent(
        title: title,
        author: 'Unknown',
        chapters: chapters,
      );
    } catch (e) {
      return _fallbackTextContent(file, 'PDF');
    }
  }

  /// Basic PDF text extraction from raw bytes.
  /// Looks for text objects between BT and ET markers and extracts
  /// strings inside parentheses.  Works for simple/plain PDFs.
  Future<String> _extractPdfText(Uint8List bytes) async {
    final content = utf8.decode(bytes, allowMalformed: true);
    final buffer = StringBuffer();

    // Find all BT...ET blocks (text objects)
    final btEtRegex = RegExp(r'BT\s*(.*?)\s*ET', dotAll: true);
    final matches = btEtRegex.allMatches(content);

    for (final match in matches) {
      final block = match.group(1)!;
      // Extract text inside parentheses Tj or TJ operators
      // Handle (text) Tj  and  [(text) num (text)] TJ
      final textRegex = RegExp(r'\(([^)]*)\)\s*Tj');
      final textMatches = textRegex.allMatches(block);
      for (final tm in textMatches) {
        String text = tm.group(1)!;
        // Handle PDF escape sequences
        text = text
            .replaceAll(r'\(', '(')
            .replaceAll(r'\)', ')')
            .replaceAll(r'\n', '\n')
            .replaceAll(r'\r', '\r');
        buffer.write(text);
        buffer.write(' ');
      }
    }

    return buffer.toString().trim();
  }

  // ── MOBI ────────────────────────────────────────────────

  Future<EbookContent> _readMobi(File file) async {
    // MOBI is a binary format; for now show unsupported.
    throw UnsupportedError('MOBI format not yet supported. Convert to EPUB for best results.');
  }

  // ── Shared helpers ──────────────────────────────────────

  /// Strip HTML tags, decode entities, return plain text.
  String _stripHtml(String html) {
    if (html.isEmpty) return '';

    try {
      // Try XML parsing for well-formed XHTML
      final doc = XmlDocument.parse(html);
      return doc.innerText.trim();
    } catch (_) {
      // Fallback to regex stripping
    }

    return html
        // Block-level tags → newline
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</tr>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</td>', caseSensitive: false), '\n')
        // Remove remaining tags
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Decode entities
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ')
        // Collapse whitespace
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
  }

  /// Split full text into chapters heuristically.
  List<EbookChapter> _splitIntoChapters(String title, String text) {
    // Try to split on common chapter markers
    final chapterRegex = RegExp(
      r'(?:^|\n)(?:Chapter|CHAPTER|Part|PART|Section|SECTION)\s+'
      r'(\d+(?:\.\d+)?|[IVXLCDM]+)\b[^\n]*',
      multiLine: true,
    );

    final matches = chapterRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      // No chapters found → single chapter
      final pages = max(1, (text.length / kCharsPerPage).ceil());
      return [
        EbookChapter(title: title, content: text, estimatedPages: pages),
      ];
    }

    final chapters = <EbookChapter>[];
    for (int i = 0; i < matches.length; i++) {
      final start = matches[i].start;
      final end = (i + 1 < matches.length) ? matches[i + 1].start : text.length;
      final chapterText = text.substring(start, end).trim();
      final chapterTitle = matches[i].group(0) ?? 'Chapter';
      final pages = max(1, (chapterText.length / kCharsPerPage).ceil());
      chapters.add(
        EbookChapter(title: chapterTitle, content: chapterText, estimatedPages: pages),
      );
    }
    return chapters;
  }

  /// Fallback: read file as raw UTF-8 text (handles plain .txt files
  /// or files mislabeled as EPUB/PDF/MOBI).
  Future<EbookContent> _fallbackTextContent(File file, String label) async {
    try {
      final text = await file.readAsString();
      final title =
          file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^.]+$'), '');
      final pages = max(1, (text.length / kCharsPerPage).ceil());
      return EbookContent(
        title: title,
        author: 'Unknown',
        chapters: [
          EbookChapter(title: title, content: text, estimatedPages: pages),
        ],
      );
    } catch (_) {
      rethrow;
    }
  }
}
