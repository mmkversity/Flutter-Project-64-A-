class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.note,
    required this.isDone,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String note;
  final bool isDone;
  final DateTime createdAt;

  TodoItem copyWith({
    String? id,
    String? title,
    String? note,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'note': note,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      note: json['note'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}