import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'dart:typed_data';

import 'ebook_content_service.dart';
import 'html_stripper.dart';

/// Extracts plain-text content from PDF files by decompressing
/// FlateDecode streams and extracting BT/ET text objects.
///
/// Heavy decompression runs on a background isolate to keep the UI thread free.
class PdfTextExtractor {
  /// Read a PDF file and extract its text content.
  static Future<EbookContent> readPdf(File file) async {
    final bytes = await file.readAsBytes();
    try {
      final text = await _extractPdfText(bytes);

      if (text.trim().isEmpty) {
        throw FormatException('No text content found in PDF');
      }

      final title =
          file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^.]+$'), '');
      final chapters = HtmlStripper.splitIntoChapters(title, text);

      return EbookContent(
        title: title,
        author: 'Unknown',
        chapters: chapters,
      );
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  /// Extract text from a PDF file, running the heavy work on a background isolate.
  static Future<String> _extractPdfText(Uint8List bytes) async {
    try {
      return await Isolate.run(() => _extractPdfTextSync(bytes));
    } catch (_) {
      return '';
    }
  }

  /// Synchronous PDF text extraction — designed to run on a background isolate.
  static String _extractPdfTextSync(Uint8List bytes) {
    final content = latin1.decode(bytes);

    String text = _extractTextFromContentStatic(content);
    if (text.isNotEmpty) return text;

    text = _extractTextFromFlateStreamsStatic(bytes, content);
    if (text.isNotEmpty) return text;

    final lastResort = _extractTextFromRawStreamsStatic(content);
    if (lastResort.isNotEmpty) return lastResort;

    return '';
  }

  /// Extract text from BT/ET blocks in raw PDF content.
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

    final tjRegex = RegExp(r'\(([^)]*)\)\s*Tj');
    for (final tm in tjRegex.allMatches(block)) {
      buffer.write(_unescapePdfStringStatic(tm.group(1)!));
      buffer.write(' ');
    }

    for (final m in RegExp(r'\[(.*?)\]\s*TJ', dotAll: true)
        .allMatches(block)) {
      final tjArrayRegex =
          RegExp(r'\(([^)]*)\)\s*(?:-?\d+(?:\.\d+)?\s*)?');
      for (final item in tjArrayRegex.allMatches(m.group(1)!)) {
        buffer.write(_unescapePdfStringStatic(item.group(1)!));
      }
      buffer.write(' ');
    }

    return buffer.toString();
  }

  /// Unescape PDF string escape sequences.
  static String _unescapePdfStringStatic(String s) {
    return s
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t')
        .replaceAll(r'\\', '\\');
  }

  /// Find FlateDecode streams, decompress with zlib, extract text.
  static String _extractTextFromFlateStreamsStatic(
      Uint8List bytes, String content) {
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

        int dataStart = streamKeywordIdx + 6;
        if (dataStart < content.length && content[dataStart] == '\r')
          dataStart++;
        if (dataStart < content.length && content[dataStart] == '\n')
          dataStart++;

        final endstreamIdx = content.indexOf('endstream', dataStart);
        if (endstreamIdx < 0) continue;
        if (dataStart >= endstreamIdx) continue;

        final compressed = bytes.sublist(dataStart, endstreamIdx);
        if (compressed.isEmpty) continue;

        final decompressed = zlib.decode(compressed);
        final decodedContent = latin1.decode(decompressed);
        final extracted = _extractTextFromContentStatic(decodedContent);
        if (extracted.isNotEmpty) {
          buffer.write(extracted);
          buffer.write('\n');
        }
      } catch (_) {}
    }

    return buffer.toString().trim();
  }

  /// Fallback: extract text from any content stream.
  static String _extractTextFromRawStreamsStatic(String content) {
    final buffer = StringBuffer();
    final streamRegex =
        RegExp(r'stream\r?\n(.*?)\r?\nendstream', dotAll: true);

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
}
