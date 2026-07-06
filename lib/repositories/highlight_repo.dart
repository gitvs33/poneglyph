import '../models/highlight.dart';

/// Persistence interface for Highlight entities.
abstract class HighlightRepo {
  Future<List<Highlight>> getHighlights(String bookId);
  Future<List<Highlight>> getAllHighlights();
  Future<void> saveHighlight(Highlight highlight);
  Future<void> deleteHighlight(String id);
}
