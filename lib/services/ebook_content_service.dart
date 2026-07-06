import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'dart:typed_data';
import 'package:archive/archive.dart';
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
    final bytes = await file.readAsBytes();

    // Try epubx first (handles most well-formed EPUBs).
    try {
      final book = await EpubReader.readBook(bytes);

      final chapters = <EbookChapter>[];
      if (book.Chapters != null) {
        for (final ch in book.Chapters!) {
          chapters.add(_epubChapterToEbook(ch));
        }
      }
      final flat = _flattenChapters(chapters);

      final coverBytes =
          book.CoverImage != null ? book.CoverImage!.getBytes() : null;

      return EbookContent(
        title: book.Title ?? file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^.]+$'), ''),
        author: book.Author ?? 'Unknown',
        chapters: flat,
        coverImageBytes: coverBytes,
      );
    } catch (_) {
      // epubx failed — fall back to manual parsing.
      // Some EPUBs use non-standard structures that confuse epubx.
    }

    // Manual EPUB parsing via archive package.
    return _readEpubManual(bytes, file);
  }

  /// Parse an EPUB using the [archive] package directly.
  /// This handles EPUBs that epubx chokes on.
  Future<EbookContent> _readEpubManual(Uint8List bytes, File file) async {
    late Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      throw Exception('Failed to unzip EPUB: $e');
    }

    // 1. Find META-INF/container.xml
    final containerFile = _findEntry(archive, 'META-INF/container.xml');
    if (containerFile == null) {
      throw Exception('Invalid EPUB: missing META-INF/container.xml');
    }

    // 2. Parse container.xml to get rootfile (OPF) path
    final containerXml = utf8.decode(containerFile.content as List<int>);
    String opfPath;
    try {
      final doc = XmlDocument.parse(containerXml);
      final rootfile = doc.findAllElements('rootfile').first;
      opfPath = rootfile.getAttribute('full-path') ?? '';
    } catch (e) {
      throw Exception('Invalid EPUB: cannot parse container.xml ($e)');
    }
    if (opfPath.isEmpty) {
      throw Exception('Invalid EPUB: rootfile path empty in container.xml');
    }

    // 2b. Resolve base directory of the OPF (for relative paths)
    final opfDir = opfPath.contains('/')
        ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1)
        : '';

    // 3. Parse OPF for manifest and spine
    final opfEntry = _findEntry(archive, opfPath);
    if (opfEntry == null) {
      throw Exception('Invalid EPUB: OPF file not found: $opfPath');
    }

    final opfXml = utf8.decode(opfEntry.content as List<int>);
    late XmlDocument opfDoc;
    try {
      opfDoc = XmlDocument.parse(opfXml);
    } catch (e) {
      throw Exception('Invalid EPUB: cannot parse OPF ($e)');
    }

    // Parse manifest: id → href, media-type
    final manifest = <String, String>{};
    for (final item in opfDoc.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id != null && href != null) {
        manifest[id] = href;
      }
    }

    // Parse spine: ordered list of idrefs
    final spineRefs = <String>[];
    for (final itemref in opfDoc.findAllElements('itemref')) {
      final idref = itemref.getAttribute('idref');
      if (idref != null) {
        spineRefs.add(idref);
      }
    }

    // Parse metadata for title and author
    String title = '';
    String author = '';
    final metadata = opfDoc.findAllElements('metadata').firstOrNull;
    if (metadata != null) {
      final titleEl = metadata.findElements('title').firstOrNull;
      if (titleEl != null) title = titleEl.innerText.trim();

      // dc:creator with namespace
      for (final el in metadata.findElements('creator')) {
        author = el.innerText.trim();
        if (author.isNotEmpty) break;
      }
    }
    if (title.isEmpty) {
      title = file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^.]+$'), '');
    }

    // 4. Read spine-ordered HTML files, strip HTML, produce chapters
    final chapters = <EbookChapter>[];
    for (int i = 0; i < spineRefs.length; i++) {
      final idref = spineRefs[i];
      final href = manifest[idref];
      if (href == null) continue;

      // Resolve relative to OPF directory
      final fullPath = '$opfDir$href';
      final entry = _findEntry(archive, fullPath);
      if (entry == null) continue;

      // Read content as UTF-8
      String rawContent;
      try {
        rawContent = utf8.decode(entry.content as List<int>);
      } catch (_) {
        // Binary file (image, etc.) — skip
        continue;
      }

      // Extract chapter title from HTML <title> or <h1>-<h6>
      String chapterTitle = _extractHtmlTitle(rawContent);
      if (chapterTitle.isEmpty) {
        chapterTitle = href.replaceAll(RegExp(r'\.[^.]+$'), '');
      }

      final text = _stripHtml(rawContent);
      if (text.trim().isEmpty) continue;

      final estimatedPages = max(1, (text.length / kCharsPerPage).ceil());
      chapters.add(EbookChapter(
        title: chapterTitle,
        content: text,
        estimatedPages: estimatedPages,
      ));
    }

    return EbookContent(
      title: title,
      author: author.isNotEmpty ? author : 'Unknown',
      chapters: chapters.isNotEmpty
          ? chapters
          : [EbookChapter(title: title, content: 'No readable content found', estimatedPages: 1)],
    );
  }

  /// Find an entry in a ZIP archive by case-insensitive path.
  ArchiveFile? _findEntry(Archive archive, String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    for (final entry in archive) {
      if (entry.name == normalizedPath) return entry;
    }
    // Try case-insensitive match
    final lower = normalizedPath.toLowerCase();
    for (final entry in archive) {
      if (entry.name.toLowerCase() == lower) return entry;
    }
    return null;
  }

  /// Extract the first meaningful title from HTML content.
  String _extractHtmlTitle(String html) {
    // Try <title> tag first
    final titleMatch = RegExp(r'<title[^>]*>([^<]+)</title>', caseSensitive: false).firstMatch(html);
    if (titleMatch != null) {
      final t = titleMatch.group(1)!.trim();
      if (t.isNotEmpty) return t;
    }
    // Try first <h1>-<h6>
    final hMatch = RegExp(r'<h[1-6][^>]*>([^<]+)</h[1-6]>', caseSensitive: false).firstMatch(html);
    if (hMatch != null) {
      return hMatch.group(1)!.trim();
    }
    return '';
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
    final bytes = await file.readAsBytes();
    try {
      final text = await _extractPdfText(bytes);

      if (text.trim().isEmpty) {
        throw FormatException('No text content found in PDF');
      }

      final title =
          file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^.]+$'), '');
      final chapters = _splitIntoChapters(title, text);

      return EbookContent(
        title: title,
        author: 'Unknown',
        chapters: chapters,
      );
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
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
  /// that were given an ebook extension).
  Future<EbookContent> _fallbackTextContent(File file, String label) async {
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
  }
}
