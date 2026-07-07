import '../entities/verse.dart';

abstract class BibleRepository {
  Future<List<Map<String, dynamic>>> getBooks();
  Future<List<Verse>> getChapterVerses(
    String versionId,
    int bookId,
    int chapter,
  );
  Future<Verse?> getDailyVerse(String versionId);
  Future<Verse?> getSingleVerse(
    String versionId,
    int bookId,
    int chapter,
    int verse,
  );
  Future<List<Verse>> searchFts(String query, {String? versionId});
  Future<List<Verse>> searchByText(String text, {String? versionId});
}
