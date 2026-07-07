import '../constants/bible_metadata.dart';

class ParsedReference {
  final int bookId;
  final String bookName;
  final int? chapter;
  final int? verse;
  final int? endVerse;

  const ParsedReference({
    required this.bookId,
    required this.bookName,
    this.chapter,
    this.verse,
    this.endVerse,
  });

  bool get isExactVerse => chapter != null && verse != null;
  bool get isChapterOnly => chapter != null && verse == null;
  bool get isRange => verse != null && endVerse != null;
}

class ReferenceType {
  final ParsedReference? reference;
  final String freeText;
  final bool isReference;

  const ReferenceType({
    this.reference,
    required this.freeText,
    this.isReference = false,
  });
}

class VerseReference {
  static ReferenceType parse(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return ReferenceType(freeText: '');

    final ref = _tryParseReference(trimmed);
    if (ref != null) {
      return ReferenceType(reference: ref, freeText: '', isReference: true);
    }

    return ReferenceType(freeText: trimmed);
  }

  static ParsedReference? _tryParseReference(String text) {
    final patterns = [
      // "Juan 3:16-21"
      RegExp(r'^([\w\sáéíóúÁÉÍÓÚ]+)\s+(\d+):(\d+)-(\d+)$'),
      // "Juan 3:16"
      RegExp(r'^([\w\sáéíóúÁÉÍÓÚ]+)\s+(\d+):(\d+)$'),
      // "Juan 3"
      RegExp(r'^([\w\sáéíóúÁÉÍÓÚ]+)\s+(\d+)$'),
      // "Juan"
      RegExp(r'^([\w\sáéíóúÁÉÍÓÚ]+)$'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match == null) continue;

      final bookStr = match.group(1)!.trim().toLowerCase();

      BookInfo? book = booksByName[bookStr];
      book ??= booksByAbbr[bookStr];
      if (book == null) {
        final alt = bibleBooks
            .where((b) => b.name.toLowerCase().startsWith(bookStr))
            .toList();
        if (alt.length == 1) book = alt.first;
      }

      if (book == null) return null;

      final chapter = match.group(2) != null
          ? int.tryParse(match.group(2)!)
          : null;
      final verse = match.group(3) != null
          ? int.tryParse(match.group(3)!)
          : null;
      final endVerse = match.group(4) != null
          ? int.tryParse(match.group(4)!)
          : null;

      return ParsedReference(
        bookId: book.id,
        bookName: book.name,
        chapter: chapter,
        verse: verse,
        endVerse: endVerse,
      );
    }

    return null;
  }

  static String format(
    String versionAbbr,
    String bookName,
    int chapter,
    int verse,
  ) {
    return '$bookName $chapter:$verse ($versionAbbr)';
  }

  static String formatRange(
    String versionAbbr,
    String bookName,
    int chapter,
    int startVerse,
    int endVerse,
  ) {
    return '$bookName $chapter:$startVerse-$endVerse ($versionAbbr)';
  }
}
