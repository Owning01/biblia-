import 'package:drift/drift.dart' hide Column;
import '../../core/database/app_database.dart' hide Verse, Book, BibleVersion;
import '../../domain/entities/verse.dart';
import '../../domain/repositories/bible_repository.dart';

class BibleRepositoryImpl implements BibleRepository {
  final AppDatabase _db;

  BibleRepositoryImpl(this._db);

  @override
  Future<List<Map<String, dynamic>>> getBooks() async {
    final result = await _db
        .customSelect('SELECT * FROM books ORDER BY id')
        .get();
    return result.map((r) => r.data).toList();
  }

  @override
  Future<List<Verse>> getChapterVerses(
    String versionId,
    int bookId,
    int chapter,
  ) async {
    final rows = await _db.getChapterVerses(versionId, bookId, chapter);
    return rows.map(Verse.fromMap).toList();
  }

  @override
  Future<Verse?> getDailyVerse(String versionId) async {
    final map = await _db.getDailyVerse(versionId);
    if (map == null) return null;
    return Verse.fromMap(map);
  }

  @override
  Future<Verse?> getSingleVerse(
    String versionId,
    int bookId,
    int chapter,
    int verse,
  ) async {
    final result = await _db
        .customSelect(
          'SELECT * FROM verses WHERE version_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
          variables: [
            Variable.withString(versionId),
            Variable.withInt(bookId),
            Variable.withInt(chapter),
            Variable.withInt(verse),
          ],
        )
        .get();
    if (result.isEmpty) return null;
    return Verse.fromMap(result.first.data);
  }

  @override
  Future<List<Verse>> searchFts(String query, {String? versionId}) async {
    final rows = await _db.searchFts(query, versionId: versionId);
    return rows.map(Verse.fromMap).toList();
  }

  @override
  Future<List<Verse>> searchByText(String text, {String? versionId}) async {
    final rows = await _db.searchByText(text, versionId: versionId);
    return rows.map(Verse.fromMap).toList();
  }
}
