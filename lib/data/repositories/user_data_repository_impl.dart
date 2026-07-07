import 'package:drift/drift.dart' hide Column;
import '../../core/database/app_database.dart'
    hide Bookmark, Highlight, Note, BibleVersion;
import '../../domain/entities/user_data.dart';
import '../../domain/repositories/user_data_repository.dart';

class UserDataRepositoryImpl implements UserDataRepository {
  final AppDatabase _db;

  UserDataRepositoryImpl(this._db);

  @override
  Future<List<Bookmark>> getBookmarks() async {
    final rows = await _db
        .customSelect(
          'SELECT b.*, v.content AS verse_text FROM bookmarks b '
          'LEFT JOIN verses v ON v.version_id = b.version_id '
          'AND v.book_id = b.book_id AND v.chapter = b.chapter AND v.verse = b.verse '
          'ORDER BY b.created_at DESC',
        )
        .get();
    return rows.map((r) => Bookmark.fromMap(r.data)).toList();
  }

  @override
  Future<bool> bookmarkExists(
    String versionId,
    int bookId,
    int chapter,
    int verse,
  ) async {
    final result = await _db
        .customSelect(
          'SELECT id FROM bookmarks WHERE version_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
          variables: [
            Variable.withString(versionId),
            Variable.withInt(bookId),
            Variable.withInt(chapter),
            Variable.withInt(verse),
          ],
        )
        .get();
    return result.isNotEmpty;
  }

  @override
  Future<void> toggleBookmark(
    String versionId,
    int bookId,
    int chapter,
    int verse,
  ) async {
    final existing = await _db
        .customSelect(
          'SELECT id FROM bookmarks WHERE version_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
          variables: [
            Variable.withString(versionId),
            Variable.withInt(bookId),
            Variable.withInt(chapter),
            Variable.withInt(verse),
          ],
        )
        .get();
    if (existing.isNotEmpty) {
      await _db.customUpdate(
        'DELETE FROM bookmarks WHERE id = ?',
        variables: [Variable.withInt(existing.first.data['id'] as int)],
      );
    } else {
      await _db.customInsert(
        'INSERT INTO bookmarks (version_id, book_id, chapter, verse, created_at) VALUES (?, ?, ?, ?, ?)',
        variables: [
          Variable.withString(versionId),
          Variable.withInt(bookId),
          Variable.withInt(chapter),
          Variable.withInt(verse),
          Variable.withString(DateTime.now().toIso8601String()),
        ],
      );
    }
  }

  @override
  Future<void> deleteBookmark(int id) async {
    await _db.customUpdate(
      'DELETE FROM bookmarks WHERE id = ?',
      variables: [Variable.withInt(id)],
    );
  }

  @override
  Future<void> setBookmarkFolder(int bookmarkId, int? folderId) async {
    await _db.setBookmarkFolder(bookmarkId, folderId);
  }

  @override
  Future<List<Map<String, dynamic>>> getBookmarkFolders() async {
    return _db.getBookmarkFolders();
  }

  @override
  Future<int> createBookmarkFolder(String name, String color) async {
    return _db.createBookmarkFolder(name, color);
  }

  @override
  Future<void> deleteBookmarkFolder(int id) async {
    await _db.deleteBookmarkFolder(id);
  }

  @override
  Future<List<Highlight>> getHighlights() async {
    final rows = await _db
        .customSelect(
          'SELECT h.*, v.content AS verse_text FROM highlights h '
          'LEFT JOIN verses v ON v.version_id = h.version_id '
          'AND v.book_id = h.book_id AND v.chapter = h.chapter AND v.verse = h.verse_start '
          'ORDER BY h.created_at DESC',
        )
        .get();
    return rows.map((r) => Highlight.fromMap(r.data)).toList();
  }

  @override
  Future<void> toggleHighlight(
    String versionId,
    int bookId,
    int chapter,
    int verse,
    String color,
    String? category,
  ) async {
    if (color.isEmpty) {
      await _db.customUpdate(
        'DELETE FROM highlights WHERE version_id = ? AND book_id = ? AND chapter = ? AND verse_start = ?',
        variables: [
          Variable.withString(versionId),
          Variable.withInt(bookId),
          Variable.withInt(chapter),
          Variable.withInt(verse),
        ],
      );
    } else {
      await _db.customInsert(
        'INSERT INTO highlights (version_id, book_id, chapter, verse_start, verse_end, color, category, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        variables: [
          Variable.withString(versionId),
          Variable.withInt(bookId),
          Variable.withInt(chapter),
          Variable.withInt(verse),
          Variable.withInt(verse),
          Variable.withString(color),
          Variable.withString(category ?? ''),
          Variable.withString(DateTime.now().toIso8601String()),
        ],
      );
    }
  }

  @override
  Future<List<Note>> getNotes() async {
    final rows = await _db
        .customSelect('SELECT * FROM notes ORDER BY created_at DESC')
        .get();
    return rows.map((r) => Note.fromMap(r.data)).toList();
  }

  @override
  Future<int> createNote(
    String versionId,
    int bookId,
    int chapter,
    int verse,
    String content,
  ) async {
    final now = DateTime.now().toIso8601String();
    return await _db.customInsert(
      'INSERT INTO notes (version_id, book_id, chapter, verse, content, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(versionId),
        Variable.withInt(bookId),
        Variable.withInt(chapter),
        Variable.withInt(verse),
        Variable.withString(content),
        Variable.withString(now),
        Variable.withString(now),
      ],
    );
  }

  @override
  Future<void> updateNote(int id, String content) async {
    final now = DateTime.now().toIso8601String();
    await _db.customUpdate(
      'UPDATE notes SET content = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withString(content),
        Variable.withString(now),
        Variable.withInt(id),
      ],
    );
  }

  @override
  Future<void> deleteNote(int id) async {
    await _db.customUpdate(
      'DELETE FROM note_tags WHERE note_id = ?',
      variables: [Variable.withInt(id)],
    );
    await _db.customUpdate(
      'DELETE FROM notes WHERE id = ?',
      variables: [Variable.withInt(id)],
    );
  }

  @override
  Future<void> setNoteTags(int noteId, List<String> tags) async {
    await _db.setNoteTags(noteId, tags);
  }

  @override
  Future<List<String>> getNoteTags(int noteId) async {
    return _db.getNoteTags(noteId);
  }

  @override
  Future<List<String>> getAllNoteTags() async {
    return _db.getAllNoteTags();
  }

  @override
  Future<Map<int, List<String>>> getNoteTagsMap() async {
    final rows = await _db.customSelect('SELECT * FROM note_tags').get();
    final map = <int, List<String>>{};
    for (final r in rows) {
      final noteId = r.data['note_id'] as int;
      final tag = r.data['tag'] as String;
      map.putIfAbsent(noteId, () => []).add(tag);
    }
    return map;
  }

  @override
  Future<void> addSearchHistory(String query) async {
    await _db.addSearchHistory(query);
  }

  @override
  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    return _db.getSearchHistory();
  }

  @override
  Future<void> clearSearchHistory() async {
    await _db.clearSearchHistory();
  }
}
