class ReadingProgress {
  final String bookId;
  final int currentPage;
  final int totalPages;
  final double scrollPosition;
  final DateTime lastReadAt;
  final Duration readingDuration;

  ReadingProgress({
    required this.bookId,
    this.currentPage = 0,
    this.totalPages = 0,
    this.scrollPosition = 0.0,
    DateTime? lastReadAt,
    this.readingDuration = Duration.zero,
  }) : lastReadAt = lastReadAt ?? DateTime.now();

  double get percentage => totalPages > 0 ? currentPage / totalPages : 0.0;

  ReadingProgress copyWith({
    String? bookId,
    int? currentPage,
    int? totalPages,
    double? scrollPosition,
    DateTime? lastReadAt,
    Duration? readingDuration,
  }) {
    return ReadingProgress(
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      readingDuration: readingDuration ?? this.readingDuration,
    );
  }

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'currentPage': currentPage,
    'totalPages': totalPages,
    'scrollPosition': scrollPosition,
    'lastReadAt': lastReadAt.toIso8601String(),
    'readingDuration': readingDuration.inSeconds,
  };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) => ReadingProgress(
    bookId: json['bookId'],
    currentPage: json['currentPage'],
    totalPages: json['totalPages'],
    scrollPosition: (json['scrollPosition'] as num).toDouble(),
    lastReadAt: DateTime.parse(json['lastReadAt']),
    readingDuration: Duration(seconds: json['readingDuration']),
  );
}
