import 'dart:convert';
import 'dart:io';
import '../models/highlight.dart';
import 'app_paths.dart';

/// Service for exporting and importing annotations (highlights, bookmarks)
/// as JSON files. Enabled by Import & Backup screen.
class AnnotationService {
  static const _fileName = 'annotations.json';

  /// Export highlights and bookmarks to a JSON file.
  Future<String> exportAnnotations({
    required List<Highlight> highlights,
    required Map<String, List<String>> bookmarks,
  }) async {
    final dir = await AppPaths.documentsDir;
    final file = File('${dir.path}/$_fileName');

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'highlights': highlights.map((h) => {
        'id': h.id,
        'bookId': h.bookId,
        'chapterId': h.chapterId,
        'text': h.text,
        'note': h.note,
        'color': h.color.name,
        'startOffset': h.startOffset,
        'endOffset': h.endOffset,
        'createdAt': h.createdAt.toIso8601String(),
      }).toList(),
      'bookmarks': bookmarks,
    };

    await file.writeAsString(jsonEncode(data));
    return file.path;
  }

  /// Import annotations from a JSON file.
  Future<Map<String, dynamic>?> importAnnotations({String? path}) async {
    final dir = await AppPaths.documentsDir;
    final file = File(path ?? '${dir.path}/$_fileName');

    if (!await file.exists()) return null;

    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    final List<Highlight>? highlights = (data['highlights'] as List?)
        ?.map((h) {
          final map = h as Map<String, dynamic>;
          return Highlight(
            id: map['id'] as String,
            bookId: map['bookId'] as String,
            chapterId: (map['chapterId'] as String?) ?? '',
            text: map['text'] as String,
            note: map['note'] as String?,
            color: HighlightColor.values.firstWhere(
              (c) => c.name == map['color'],
              orElse: () => HighlightColor.yellow,
            ),
            startOffset: (map['startOffset'] as num).toInt(),
            endOffset: (map['endOffset'] as num).toInt(),
            createdAt: map['createdAt'] != null
                ? DateTime.parse(map['createdAt'] as String)
                : null,
          );
        })
        .toList();

    final Map<String, List<String>>? bookmarks =
        (data['bookmarks'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, List<String>.from(v as List)),
    );

    return {
      'highlights': highlights ?? <Highlight>[],
      'bookmarks': bookmarks ?? <String, List<String>>{},
    };
  }

  /// Check if an annotations file exists.
  Future<bool> hasAnnotations() async {
    final dir = await AppPaths.documentsDir;
    final file = File('${dir.path}/$_fileName');
    return file.exists();
  }

  /// Delete the annotations file.
  Future<void> clearAnnotations() async {
    final dir = await AppPaths.documentsDir;
    final file = File('${dir.path}/$_fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
