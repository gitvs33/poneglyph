import '../models/reading_progress.dart';

/// Persistence interface for ReadingProgress entities.
abstract class ProgressRepo {
  Future<ReadingProgress?> getProgress(String bookId);
  Future<void> saveProgress(ReadingProgress progress);
}
