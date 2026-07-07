# 03 — API de Datos (Datasources y Repositorios)

## BibleRepository (Interfaz)

```dart
abstract class BibleRepository {
  Future<List<Book>> getBooks();
  Future<List<Book>> getBooksByTestament(Testament testament);
  Future<Book?> getBookById(int id);
  Future<List<BibleVersion>> getVersions();
  Future<List<Verse>> getChapterVerses(String versionId, int bookId, int chapter);
  Future<Verse?> getVerse(String versionId, int bookId, int chapter, int verse);
  Future<List<Verse>> getVerseRange(String versionId, int bookId, int chapter, int start, int end);
  Future<int> getChapterCount(int bookId);
  Future<bool> isVersionDownloaded(String versionId);
  Future<void> downloadVersion(String versionId);
  Future<List<String>> getInstalledVersionIds();
}
```

## SearchRepository (Interfaz)

```dart
abstract class SearchRepository {
  Future<SearchResult> search(String query, {String? versionId});
  Future<List<SearchSuggestion>> getSuggestions(String prefix);
  Future<ReferenceResult?> parseReference(String query);
}

class SearchResult {
  final List<VerseResult> verses;
  final List<BookResult> books;
  final int totalCount;
}

class VerseResult {
  final Verse verse;
  final String snippet;  // Contexto alrededor del match
}

class ReferenceResult {
  final int bookId;
  final int chapter;
  final int? verse;
  final int? endVerse;
}

class BookResult {
  final Book book;
  final int matchType; // 0=name, 1=abbreviation
}
```

## BookmarkRepository (Interfaz)

```dart
abstract class BookmarkRepository {
  Future<List<Bookmark>> getAllBookmarks();
  Future<List<Bookmark>> getBookmarksByBook(int bookId);
  Future<void> addBookmark(Bookmark bookmark);
  Future<void> removeBookmark(int id);
  Future<bool> isBookmarked(String versionId, int bookId, int chapter, int verse);
}
```

## HighlightRepository (Interfaz)

```dart
abstract class HighlightRepository {
  Future<List<Highlight>> getAllHighlights();
  Future<List<Highlight>> getHighlightsByChapter(String versionId, int bookId, int chapter);
  Future<void> addHighlight(Highlight highlight);
  Future<void> removeHighlight(int id);
  Future<void> updateHighlightColor(int id, String color);
}
```

## NoteRepository (Interfaz)

```dart
abstract class NoteRepository {
  Future<List<Note>> getAllNotes();
  Future<List<Note>> getNotesByVerse(String versionId, int bookId, int chapter, int verse);
  Future<void> addNote(Note note);
  Future<void> updateNote(int id, String content);
  Future<void> removeNote(int id);
}
```

## ReadingPlanRepository (Interfaz)

```dart
abstract class ReadingPlanRepository {
  Future<List<ReadingPlan>> getPlans();
  Future<ReadingPlan?> getPlanById(int id);
  Future<List<ReadingPlanDay>> getPlanDays(int planId);
  Future<void> markDayCompleted(int planId, int day);
  Future<void> unmarkDayCompleted(int planId, int day);
  Future<bool> isDayCompleted(int planId, int day);
  Future<int> getProgress(int planId);
}
```

## Versión remota (descarga de nuevas biblias)

```dart
abstract class BibleRemoteDatasource {
  Future<List<BibleVersion>> getAvailableVersions();
  Future<void> downloadVersion(String versionId, {void Function(double)? onProgress});
  Future<String?> getVersionUrl(String versionId);
}
```
