import 'dart:math';

import 'package:xml/xml.dart';

import 'ebook_content_service.dart';

/// Pure functions for HTML-to-text conversion and chapter splitting.
class HtmlStripper {
  /// Strip HTML tags, decode entities, return plain text.
  static String stripHtml(String html) {
    if (html.isEmpty) return '';

    try {
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
  static List<EbookChapter> splitIntoChapters(String title, String text) {
    final chapterRegex = RegExp(
      r'(?:^|\n)(?:Chapter|CHAPTER|Part|PART|Section|SECTION)\s+'
      r'(\d+(?:\.\d+)?|[IVXLCDM]+)\b[^\n]*',
      multiLine: true,
    );

    final matches = chapterRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      final pages = max(1, (text.length / kCharsPerPage).ceil());
      return [
        EbookChapter(title: title, content: text, estimatedPages: pages),
      ];
    }

    final chapters = <EbookChapter>[];
    for (int i = 0; i < matches.length; i++) {
      final start = matches[i].start;
      final end =
          (i + 1 < matches.length) ? matches[i + 1].start : text.length;
      final chapterText = text.substring(start, end).trim();
      final chapterTitle = matches[i].group(0) ?? 'Chapter';
      final pages = max(1, (chapterText.length / kCharsPerPage).ceil());
      chapters.add(EbookChapter(
        title: chapterTitle,
        content: chapterText,
        estimatedPages: pages,
      ));
    }
    return chapters;
  }

  /// Extract the first meaningful title from HTML content.
  static String extractHtmlTitle(String html) {
    // Try <title> tag first
    final titleMatch = RegExp(
      r'<title[^>]*>([^<]+)</title>',
      caseSensitive: false,
    ).firstMatch(html);
    if (titleMatch != null) {
      final t = titleMatch.group(1)!.trim();
      if (t.isNotEmpty) return t;
    }
    // Try first <h1>-<h6>
    final hMatch = RegExp(
      r'<h[1-6][^>]*>([^<]+)</h[1-6]>',
      caseSensitive: false,
    ).firstMatch(html);
    if (hMatch != null) {
      return hMatch.group(1)!.trim();
    }
    return '';
  }
}
