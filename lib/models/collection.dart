class Collection {
  final String id;
  final String name;
  final String? icon;
  final int bookCount;
  final DateTime createdAt;
  final List<String> bookIds;

  Collection({
    required this.id,
    required this.name,
    this.icon,
    this.bookCount = 0,
    DateTime? createdAt,
    this.bookIds = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Collection copyWith({
    String? id,
    String? name,
    String? icon,
    int? bookCount,
    DateTime? createdAt,
    List<String>? bookIds,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      bookCount: bookCount ?? this.bookCount,
      createdAt: createdAt ?? this.createdAt,
      bookIds: bookIds ?? this.bookIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'bookCount': bookCount,
    'createdAt': createdAt.toIso8601String(),
    'bookIds': bookIds,
  };

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
    id: json['id'],
    name: json['name'],
    icon: json['icon'],
    bookCount: json['bookCount'] ?? 0,
    createdAt: DateTime.parse(json['createdAt']),
    bookIds: List<String>.from(json['bookIds'] ?? []),
  );
}
