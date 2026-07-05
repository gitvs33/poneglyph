enum BookFormat { epub, pdf, mobi }

enum BookSource { device, url, googleDrive, dropbox, oneDrive, iCloud }

class Book {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final String? description;
  final BookFormat format;
  final BookSource source;
  final DateTime addedAt;
  final DateTime? lastOpenedAt;
  final double progress;
  final int totalPages;
  final int currentPage;
  final List<String> tags;
  final String? collectionId;
  final bool isFavorite;
  final String? filePath;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
    required this.format,
    this.source = BookSource.device,
    DateTime? addedAt,
    this.lastOpenedAt,
    this.progress = 0.0,
    this.totalPages = 0,
    this.currentPage = 0,
    this.tags = const [],
    this.collectionId,
    this.isFavorite = false,
    this.filePath,
  }) : addedAt = addedAt ?? DateTime.now();

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverUrl,
    String? description,
    BookFormat? format,
    BookSource? source,
    DateTime? addedAt,
    DateTime? lastOpenedAt,
    double? progress,
    int? totalPages,
    int? currentPage,
    List<String>? tags,
    String? collectionId,
    bool? isFavorite,
    String? filePath,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      format: format ?? this.format,
      source: source ?? this.source,
      addedAt: addedAt ?? this.addedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      progress: progress ?? this.progress,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      tags: tags ?? this.tags,
      collectionId: collectionId ?? this.collectionId,
      isFavorite: isFavorite ?? this.isFavorite,
      filePath: filePath ?? this.filePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'coverUrl': coverUrl,
    'description': description,
    'format': format.name,
    'source': source.name,
    'addedAt': addedAt.toIso8601String(),
    'lastOpenedAt': lastOpenedAt?.toIso8601String(),
    'progress': progress,
    'totalPages': totalPages,
    'currentPage': currentPage,
    'tags': tags,
    'collectionId': collectionId,
    'isFavorite': isFavorite,
    'filePath': filePath,
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'],
    author: json['author'],
    coverUrl: json['coverUrl'],
    description: json['description'],
    format: BookFormat.values.firstWhere((e) => e.name == json['format']),
    source: BookSource.values.firstWhere((e) => e.name == json['source']),
    addedAt: DateTime.parse(json['addedAt']),
    lastOpenedAt: json['lastOpenedAt'] != null ? DateTime.parse(json['lastOpenedAt']) : null,
    progress: (json['progress'] as num).toDouble(),
    totalPages: json['totalPages'],
    currentPage: json['currentPage'],
    tags: List<String>.from(json['tags']),
    collectionId: json['collectionId'],
    isFavorite: json['isFavorite'] ?? false,
    filePath: json['filePath'],
  );
}
