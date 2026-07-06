import 'dart:convert';
import "dart:typed_data";
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:epubx/epubx.dart';
import 'package:xml/xml.dart';

import 'ebook_content_service.dart';
import 'html_stripper.dart';

/// Extracts plain-text content from EPUB files by parsing ZIP,
/// OPF manifest/spine, and HTML stripping.
class EpubParser {
  /// Read an EPUB file and return parsed content.
  /// Tries manual ZIP-based parser first, falls back to epubx for cover images.
  static Future<EbookContent> readEpub(File file) async {
    final bytes = await file.readAsBytes();

    final result = await readEpubManual(bytes, file);

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
  static Future<EbookContent> readEpubManual(
      Uint8List bytes, File file) async {
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

    final opfDir = opfPath.contains('/')
        ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1)
        : '';

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

    final manifest = <String, String>{};
    for (final item in opfDoc.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id != null && href != null) {
        manifest[id] = href;
      }
    }

    final spineRefs = <String>[];
    for (final itemref in opfDoc.findAllElements('itemref')) {
      final idref = itemref.getAttribute('idref');
      if (idref != null) {
        spineRefs.add(idref);
      }
    }

    String title = '';
    String author = '';
    final metadata = opfDoc.findAllElements('metadata').firstOrNull;
    if (metadata != null) {
      final titleEl =
          metadata.findElements('title', namespace: '*').firstOrNull;
      if (titleEl != null) title = titleEl.innerText.trim();
      for (final el in metadata.findElements('creator', namespace: '*')) {
        author = el.innerText.trim();
        if (author.isNotEmpty) break;
      }
    }
    if (title.isEmpty) {
      title =
          file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^.]+$'), '');
    }

    final chapters = <EbookChapter>[];
    for (int i = 0; i < spineRefs.length; i++) {
      final idref = spineRefs[i];
      final href = manifest[idref];
      if (href == null) continue;

      ArchiveFile? entry = _findEntry(archive, '$opfDir$href');
      if (entry == null) {
        entry = _findEntry(archive, href);
      }
      if (entry == null) continue;

      final raw = entry.content;
      if (raw == null) continue;
      String rawContent;
      try {
        rawContent = _decodeEntryText(raw);
      } catch (_) {
        continue;
      }

      String chapterTitle = HtmlStripper.extractHtmlTitle(rawContent);
      if (chapterTitle.isEmpty) {
        chapterTitle = href.replaceAll(RegExp(r'\.[^.]+$'), '');
      }

      final text = HtmlStripper.stripHtml(rawContent);
      if (text.trim().isEmpty) continue;

      final estimatedPages =
          text.length > 0 ? (text.length / kCharsPerPage).ceil() : 1;
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
          : [
              EbookChapter(
                title: title,
                content: 'No readable content found',
                estimatedPages: 1,
              )
            ],
    );
  }

  /// Safely decode entry content (which may be List<int> or Uint8List) to text.
  static String _decodeEntryText(dynamic content) {
    if (content is Uint8List) {
      return utf8.decode(content);
    } else if (content is List<int>) {
      return utf8.decode(content);
    } else if (content is String) {
      return content;
    }
    throw FormatException(
        'Cannot decode entry content of type ${content.runtimeType}');
  }

  /// Find an entry in a ZIP archive by case-insensitive path.
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
