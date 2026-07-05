enum HighlightColor { yellow, green, blue, pink, underline }

class Highlight {
  final String id;
  final String bookId;
  final String chapterId;
  final String text;
  final String? note;
  final HighlightColor color;
  final int startOffset;
  final int endOffset;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Highlight({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.text,
    this.note,
    this.color = HighlightColor.yellow,
    required this.startOffset,
    required this.endOffset,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Highlight copyWith({
    String? id,
    String? bookId,
    String? chapterId,
    String? text,
    String? note,
    HighlightColor? color,
    int? startOffset,
    int? endOffset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Highlight(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      text: text ?? this.text,
      note: note ?? this.note,
      color: color ?? this.color,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'chapterId': chapterId,
    'text': text,
    'note': note,
    'color': color.name,
    'startOffset': startOffset,
    'endOffset': endOffset,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
    id: json['id'],
    bookId: json['bookId'],
    chapterId: json['chapterId'],
    text: json['text'],
    note: json['note'],
    color: HighlightColor.values.firstWhere((e) => e.name == json['color']),
    startOffset: json['startOffset'],
    endOffset: json['endOffset'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );
}
