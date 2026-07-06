import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
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
  /// Detect the book format by reading the file header (magic bytes).
  /// This is more reliable than trusting the file extension.
  static Future<BookFormat> detectFormat(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return BookFormat.epub;
      
      final raf = await file.open(mode: FileMode.read);
      try {
        // Read first 8 bytes for signature detection
        final header = await raf.read(8);
        if (header.length < 4) return BookFormat.epub; // too small, default
        
        // PDF: %PDF
        if (header[0] == 0x25 && header[1] == 0x50 && 
            header[2] == 0x44 && header[3] == 0x46) {
          return BookFormat.pdf;
        }
        
        // ZIP (EPUB): PK\3\4
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
    } catch (_) {
      // On error, fall through to default
    }
    
    return BookFormat.epub;
  }

  /// Read an ebook from [filePath] in the given [format].
  /// Returns null if the format is not supported or the file can't be parsed.
  Future<EbookContent?> readBook(String filePath, BookFormat format) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    // Check actual format by magic bytes BEFORE parsing.
    // This handles books imported with wrong extension (e.g., .pdf file
    // that is actually an EPUB, or vice versa).
    final actualFormat = await detectFormat(filePath);
    if (actualFormat != format) {
      format = actualFormat;
    }

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

    // Parse EPUB directly via archive package — handles all
    // standard EPUB structures regardless of TOC format.
    // Only falls back to epubx for cover image extraction.
    final result = await _readEpubManual(bytes, file);

    // Try to get cover image from epubx (nice-to-have).
    try {
      final book = await EpubReader.readBook(bytes);
      if (result.coverImageBytes == null && book.CoverImage != null) {
        return EbookContent(
          title: result.title,
          author: result.author,
          chapters: result.chapters,
          coverImageBytes: book.CoverImage!.getBytes(),
        );
      }
    } catch (_) {
      // Cover image is optional — ignore failures.
    }

    return result;
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
    final containerRaw = containerFile.content;
    if (containerRaw == null) {
      throw Exception('Invalid EPUB: empty container.xml');
    }
    final containerXml = _decodeEntryText(containerRaw);
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
    final opfRaw = opfEntry.content;
    if (opfRaw == null) {
      throw Exception('Invalid EPUB: empty OPF file');
    }
    final opfXml = _decodeEntryText(opfRaw);
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
      final titleEl = metadata.findElements('title', namespace: '*').firstOrNull;
      if (titleEl != null) title = titleEl.innerText.trim();

      for (final el in metadata.findElements('creator', namespace: '*')) {
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

      // Resolve path: some EPUBs use paths relative to OPF dir,
      // others use paths relative to EPUB root.
      ArchiveFile? entry = _findEntry(archive, '$opfDir$href');
      if (entry == null) {
        // Try href as-is (root-relative path)
        entry = _findEntry(archive, href);
      }
      if (entry == null) continue;

      // Read content
      final raw = entry.content;
      if (raw == null) continue;
      String rawContent;
      try {
        rawContent = _decodeEntryText(raw);
      } catch (_) {
        // Binary file (image, etc.) — skip
        continue;
      }

      // Skip if not HTML (check for DOCTYPE or html tag or typical XML)
      final trimmed = rawContent.trimLeft();
      if (!trimmed.startsWith('<') && !trimmed.startsWith('<?xml')) {
        // Not markup — try anyway as plain text
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

  /// Safely decode entry content (which may be List<int> or Uint8List) to text.
  String _decodeEntryText(dynamic content) {
    if (content is Uint8List) {
      return utf8.decode(content);
    } else if (content is List<int>) {
      return utf8.decode(content);
    } else if (content is String) {
      return content;
    }
    throw FormatException('Cannot decode entry content of type ${content.runtimeType}');
  }

  /// Find an entry in a ZIP archive by case-insensitive path.
  /// Handles leading './', extra slashes, and cross-platform separators.
  ArchiveFile? _findEntry(Archive archive, String path) {
    // Normalize to forward slashes, strip leading './' or '/'
    String normalizedPath = path.replaceAll('\\', '/').replaceAll('//', '/');
    while (normalizedPath.startsWith('./') || normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.startsWith('./')
          ? normalizedPath.substring(2)
          : normalizedPath.substring(1);
    }

    // Exact match
    for (final entry in archive) {
      if (entry.name == normalizedPath) return entry;
    }

    // Case-insensitive match
    final lower = normalizedPath.toLowerCase();
    for (final entry in archive) {
      if (entry.name.toLowerCase() == lower) return entry;
    }

    // Try stripping any directory prefix from the path and matching
    // just the filename (some EPUBs flatten paths oddly)
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

  /// Extract text from a PDF file.
  /// First tries simple regex on raw bytes (fast path for uncompressed PDFs).
  /// Extract text from a PDF file, running the heavy work on a background isolate.
  Future<String> _extractPdfText(Uint8List bytes) async {
    // Move zlib decompression and regex to a background isolate
    // so the UI thread doesn't freeze on large PDFs.
    try {
      return await Isolate.run(() => _extractPdfTextSync(bytes));
    } catch (_) {
      return '';
    }
  }

  /// Synchronous PDF text extraction — designed to run on a background isolate.
  static String _extractPdfTextSync(Uint8List bytes) {
    // latin1 is a lossless 1:1 byte<->char mapping — string offsets are exact byte offsets.
    // (utf8.decode with allowMalformed collapses invalid multi-byte sequences into a single
    // U+FFFD, which desyncs string position from byte position on any binary/compressed data.)
    final content = latin1.decode(bytes);

    // Fast path: try BT/ET on raw bytes (works for simple/uncompressed PDFs)
    String text = _extractTextFromContentStatic(content);
    if (text.isNotEmpty) return text;

    // Slower path: find FlateDecode (zlib) streams, decompress, extract text
    text = _extractTextFromFlateStreamsStatic(bytes, content);
    if (text.isNotEmpty) return text;

    // Last resort: try extracting from any stream regardless of filter
    final lastResort = _extractTextFromRawStreamsStatic(content);
    if (lastResort.isNotEmpty) return lastResort;

    return '';
  }

  /// Extract text from BT/ET blocks in raw PDF content (static version).
  static String _extractTextFromContentStatic(String content) {
    final buffer = StringBuffer();
    final btEtRegex = RegExp(r'BT\s*(.*?)\s*ET', dotAll: true);
    final matches = btEtRegex.allMatches(content);

    for (final match in matches) {
      final block = match.group(1)!;
      final text = _extractOperatorsStatic(block);
      buffer.write(text);
      buffer.write(' ');
    }

    return buffer.toString().trim();
  }

  /// Extract text from parentheses-based operators in a PDF content block.
  static String _extractOperatorsStatic(String block) {
    final buffer = StringBuffer();

    // (text) Tj  — single text show
    final tjRegex = RegExp(r'\(([^)]*)\)\s*Tj');
    for (final tm in tjRegex.allMatches(block)) {
      buffer.write(_unescapePdfStringStatic(tm.group(1)!));
      buffer.write(' ');
    }

    // [(text) num (text)] TJ  — array text show with positioning
    for (final m in RegExp(r'\[(.*?)\]\s*TJ', dotAll: true).allMatches(block)) {
      final tjArrayRegex = RegExp(r'\(([^)]*)\)\s*(?:-?\d+(?:\.\d+)?\s*)?');
      for (final item in tjArrayRegex.allMatches(m.group(1)!)) {
        buffer.write(_unescapePdfStringStatic(item.group(1)!));
      }
      buffer.write(' ');
    }

    return buffer.toString();
  }

  /// Unescape PDF string escape sequences (static version).
  static String _unescapePdfStringStatic(String s) {
    return s
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t')
        .replaceAll(r'\\', '\\');
  }

  /// Find FlateDecode streams, decompress with zlib, extract text (static).
  ///
  /// Uses latin1.decode (lossless byte↔char) so that string indices from regex
  /// matches are directly usable as byte indices into the original Uint8List — no
  /// expensive utf8.encode round-trip needed.
  static String _extractTextFromFlateStreamsStatic(Uint8List bytes, String content) {
    final buffer = StringBuffer();

    final objRegex = RegExp(
      r'obj\s*<<[^>]*/Filter\s*\[?\s*/FlateDecode[^>]*>>\s*stream\r?\n(.*?)\r?\nendstream',
      dotAll: true,
      caseSensitive: false,
    );

    for (final objMatch in objRegex.allMatches(content)) {
      try {
        final streamKeywordIdx = content.indexOf('stream', objMatch.start);
        if (streamKeywordIdx < 0) continue;

        int dataStart = streamKeywordIdx + 6; // 'stream'.length
        if (dataStart < content.length && content[dataStart] == '\r') dataStart++;
        if (dataStart < content.length && content[dataStart] == '\n') dataStart++;

        final endstreamIdx = content.indexOf('endstream', dataStart);
        if (endstreamIdx < 0) continue;
        if (dataStart >= endstreamIdx) continue;

        // latin1 => string index IS byte index, no need for utf8.encode conversion
        final compressed = bytes.sublist(dataStart, endstreamIdx);
        if (compressed.isEmpty) continue;

        // Decompress with zlib
        final decompressed = zlib.decode(compressed);
        final decodedContent = latin1.decode(decompressed);
        final extracted = _extractTextFromContentStatic(decodedContent);
        if (extracted.isNotEmpty) {
          buffer.write(extracted);
          buffer.write('\n');
        }
      } catch (_) {
        // Skip streams that fail to decompress
      }
    }

    return buffer.toString().trim();
  }

  /// Fallback: extract text from any content stream (static version).
  static String _extractTextFromRawStreamsStatic(String content) {
    final buffer = StringBuffer();
    final streamRegex = RegExp(
      r'stream\r?\n(.*?)\r?\nendstream',
      dotAll: true,
    );

    for (final match in streamRegex.allMatches(content)) {
      final raw = match.group(1)!;
      try {
        final text = _extractTextFromContentStatic(raw);
        if (text.isNotEmpty) {
          buffer.write(text);
          buffer.write('\n');
        }
      } catch (_) {}
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
