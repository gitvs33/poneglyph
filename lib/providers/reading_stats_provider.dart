import 'package:flutter/material.dart';
import '../models/reading_session.dart';

class ReadingStatsProvider extends ChangeNotifier {
  final List<ReadingSession> _sessions = [];
  int _readingStreak = 0;
  int _booksFinished = 0;

  List<ReadingSession> get sessions => List.unmodifiable(_sessions);
  int get readingStreak => _readingStreak;
  int get booksFinished => _booksFinished;

  Duration get totalTimeRead {
    Duration total = Duration.zero;
    for (final session in _sessions) {
      total += session.duration;
    }
    return total;
  }

  int get totalPagesRead {
    int pages = 0;
    for (final session in _sessions) {
      pages += session.pagesRead;
    }
    return pages;
  }

  Map<String, int> get weeklyChart {
    final weekData = <String, int>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.month}/${day.day}';
      weekData[key] = 0;
    }
    for (final session in _sessions) {
      if (session.endTime != null) {
        final diff = now.difference(session.startTime).inDays;
        if (diff >= 0 && diff < 7) {
          final key = '${session.startTime.month}/${session.startTime.day}';
          weekData[key] = (weekData[key] ?? 0) + session.duration.inMinutes;
        }
      }
    }
    return weekData;
  }

  void addSession(ReadingSession session) {
    _sessions.add(session);
    notifyListeners();
  }

  void incrementBooksFinished() {
    _booksFinished++;
    notifyListeners();
  }

  void updateStreak() {
    // In production, calculate actual streak from sessions
    _readingStreak++;
    notifyListeners();
  }
}
