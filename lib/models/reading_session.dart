class ReadingSession {
  final String id;
  final String bookId;
  final DateTime startTime;
  final DateTime? endTime;
  final int pagesRead;
  final String? chapterId;

  ReadingSession({
    required this.id,
    required this.bookId,
    required this.startTime,
    this.endTime,
    this.pagesRead = 0,
    this.chapterId,
  });

  Duration get duration {
    if (endTime == null) return Duration.zero;
    return endTime!.difference(startTime);
  }

  bool get isActive => endTime == null;

  ReadingSession end() {
    return ReadingSession(
      id: id,
      bookId: bookId,
      startTime: startTime,
      endTime: DateTime.now(),
      pagesRead: pagesRead,
      chapterId: chapterId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'pagesRead': pagesRead,
    'chapterId': chapterId,
  };

  factory ReadingSession.fromJson(Map<String, dynamic> json) => ReadingSession(
    id: json['id'],
    bookId: json['bookId'],
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    pagesRead: json['pagesRead'],
    chapterId: json['chapterId'],
  );
}
