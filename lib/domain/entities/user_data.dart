class Bookmark {
  final int id;
  final String versionId;
  final int bookId;
  final int chapter;
  final int verse;
  final String? label;
  final String? verseText;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.versionId,
    required this.bookId,
    required this.chapter,
    required this.verse,
    this.label,
    this.verseText,
    required this.createdAt,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int,
      versionId: map['version_id'] as String,
      bookId: map['book_id'] as int,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      label: map['label'] as String?,
      verseText: map['verse_text'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class Highlight {
  final int id;
  final String versionId;
  final int bookId;
  final int chapter;
  final int verseStart;
  final int verseEnd;
  final String color;
  final String? verseText;
  final DateTime createdAt;

  const Highlight({
    required this.id,
    required this.versionId,
    required this.bookId,
    required this.chapter,
    required this.verseStart,
    required this.verseEnd,
    required this.color,
    this.verseText,
    required this.createdAt,
  });

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      id: map['id'] as int,
      versionId: map['version_id'] as String,
      bookId: map['book_id'] as int,
      chapter: map['chapter'] as int,
      verseStart: map['verse_start'] as int,
      verseEnd: map['verse_end'] as int,
      color: map['color'] as String,
      verseText: map['verse_text'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class Note {
  final int id;
  final String versionId;
  final int bookId;
  final int chapter;
  final int verse;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.versionId,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      versionId: map['version_id'] as String,
      bookId: map['book_id'] as int,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class ReadingPlan {
  final int id;
  final String name;
  final String? description;
  final int durationDays;

  const ReadingPlan({
    required this.id,
    required this.name,
    this.description,
    required this.durationDays,
  });

  factory ReadingPlan.fromMap(Map<String, dynamic> map) {
    return ReadingPlan(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      durationDays: map['duration_days'] as int,
    );
  }
}

class ReadingPlanDay {
  final int id;
  final int planId;
  final int day;
  final String versionId;
  final int bookId;
  final int chapter;
  final int verseStart;
  final int? verseEnd;

  const ReadingPlanDay({
    required this.id,
    required this.planId,
    required this.day,
    required this.versionId,
    required this.bookId,
    required this.chapter,
    required this.verseStart,
    this.verseEnd,
  });

  factory ReadingPlanDay.fromMap(Map<String, dynamic> map) {
    return ReadingPlanDay(
      id: map['id'] as int,
      planId: map['plan_id'] as int,
      day: map['day'] as int,
      versionId: map['version_id'] as String,
      bookId: map['book_id'] as int,
      chapter: map['chapter'] as int,
      verseStart: map['verse_start'] as int,
      verseEnd: map['verse_end'] as int?,
    );
  }
}
