import 'package:flutter/material.dart';
import '../models/reading_session.dart';

enum StatsPeriod { thisWeek, thisMonth, allTime }

class ReadingStatsProvider extends ChangeNotifier {
  final List<ReadingSession> _sessions = [];
  int _readingStreak = 0;
  int _booksFinished = 0;
  StatsPeriod _selectedPeriod = StatsPeriod.thisWeek;

  List<ReadingSession> get sessions => List.unmodifiable(_sessions);
  int get readingStreak => _readingStreak;
  int get booksFinished => _booksFinished;
  StatsPeriod get selectedPeriod => _selectedPeriod;

  List<ReadingSession> get _filteredSessions {
    if (_selectedPeriod == StatsPeriod.allTime) return _sessions;
    final now = DateTime.now();
    final maxDays = _selectedPeriod == StatsPeriod.thisWeek ? 7 : 30;
    return _sessions.where((s) {
      if (s.endTime == null) return false;
      return now.difference(s.startTime).inDays < maxDays;
    }).toList();
  }

  Duration get totalTimeRead {
    Duration total = Duration.zero;
    for (final session in _filteredSessions) {
      total += session.duration;
    }
    return total;
  }

  int get totalPagesRead {
    int pages = 0;
    for (final session in _filteredSessions) {
      pages += session.pagesRead;
    }
    return pages;
  }

  Map<String, int> get weeklyChart {
    final data = <String, int>{};
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case StatsPeriod.thisWeek:
        for (int i = 6; i >= 0; i--) {
          final day = now.subtract(Duration(days: i));
          data['${day.month}/${day.day}'] = 0;
        }
        break;
      case StatsPeriod.thisMonth:
        for (int i = 29; i >= 0; i--) {
          final day = now.subtract(Duration(days: i));
          data['${day.month}/${day.day}'] = 0;
        }
        break;
      case StatsPeriod.allTime:
        const monthNames = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        for (int i = 11; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          data[monthNames[month.month - 1]] = 0;
        }
        break;
    }
    for (final session in _sessions) {
      if (session.endTime != null) {
        final sessionMinutes = session.duration.inMinutes;
        switch (_selectedPeriod) {
          case StatsPeriod.thisWeek:
            if (now.difference(session.startTime).inDays < 7) {
              final key = '${session.startTime.month}/${session.startTime.day}';
              data[key] = (data[key] ?? 0) + sessionMinutes;
            }
            break;
          case StatsPeriod.thisMonth:
            if (now.difference(session.startTime).inDays < 30) {
              final key = '${session.startTime.month}/${session.startTime.day}';
              data[key] = (data[key] ?? 0) + sessionMinutes;
            }
            break;
          case StatsPeriod.allTime:
            const monthNames = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            final key = monthNames[session.startTime.month - 1];
            data[key] = (data[key] ?? 0) + sessionMinutes;
            break;
        }
      }
    }
    return data;
  }

  void setSelectedPeriod(StatsPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
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
