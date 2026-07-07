class Verse {
  final int id;
  final String versionId;
  final int bookId;
  final int chapter;
  final int verse;
  final String text;

  const Verse({
    required this.id,
    required this.versionId,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] as int,
      versionId: map['version_id'] as String,
      bookId: map['book_id'] as int,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      text: (map['content'] ?? map['text']) as String,
    );
  }
}

class Book {
  final int id;
  final String name;
  final String abbreviation;
  final String testament;
  final int position;

  const Book({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.testament,
    required this.position,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      name: map['name'] as String,
      abbreviation: map['abbreviation'] as String,
      testament: map['testament'] as String,
      position: map['position'] as int,
    );
  }
}

class BibleVersion {
  final String id;
  final String name;
  final String abbreviation;
  final String language;
  final String? copyright;
  final bool isDownloaded;

  const BibleVersion({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.language,
    this.copyright,
    this.isDownloaded = false,
  });

  factory BibleVersion.fromMap(Map<String, dynamic> map) {
    return BibleVersion(
      id: map['id'] as String,
      name: map['name'] as String,
      abbreviation: map['abbreviation'] as String,
      language: map['language'] as String? ?? 'es',
      copyright: map['copyright'] as String?,
      isDownloaded: (map['is_downloaded'] as int? ?? 0) == 1,
    );
  }
}
