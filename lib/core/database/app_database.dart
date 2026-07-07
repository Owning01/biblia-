import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import '../constants/bible_metadata.dart';
import 'tables.dart';

part 'app_database.g.dart';

QueryExecutor _createExecutor() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'biblia.db');
    final file = File(path);

    if (!await file.exists()) {
      try {
        final data = await rootBundle.load('assets/bibles/rv1960.db');
        await file.writeAsBytes(data.buffer.asUint8List());
      } catch (_) {}
    }

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase(file);
  });
}

@DriftDatabase(
  tables: [
    BibleVersions,
    Books,
    Verses,
    Bookmarks,
    Highlights,
    Notes,
    ReadingPlans,
    ReadingPlanDays,
    ReadingProgress,
    PrayerRequests,
    PrayerActions,
    BookmarkFolders,
    SearchHistory,
    ReadingLog,
    NoteTags,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_createExecutor());

  bool _seeded = false;
  Future<void> ensureSeeded() async {
    if (_seeded) return;
    _seeded = true;
    try {
      final count = await customSelect(
        'SELECT COUNT(*) as c FROM books',
      ).getSingle();
      if (count.data['c'] as int == 0) {
        await _seedAll();
      }
    } catch (_) {}
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedAll();
      await _createFtsIndex();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(prayerRequests);
        await m.createTable(prayerActions);
      }
      if (from < 3) {
        await m.createTable(bookmarkFolders);
        await m.createTable(searchHistory);
        await m.createTable(readingLog);
        await m.createTable(noteTags);
        await m.alterTable(
          TableMigration(highlights, newColumns: [highlights.category]),
        );
        await m.alterTable(
          TableMigration(bookmarks, newColumns: [bookmarks.folderId]),
        );
      }
    },
  );

  Future<void> _seedAll() async {
    await _seedBooks();
    await _seedVersions();
    await _seedReadingPlans();
  }

  Future<void> _seedBooks() async {
    for (final book in bibleBooks) {
      await customInsert(
        'INSERT OR IGNORE INTO books (id, name, abbreviation, testament, position) VALUES (?, ?, ?, ?, ?)',
        variables: [
          Variable.withInt(book.id),
          Variable.withString(book.name),
          Variable.withString(book.abbreviation),
          Variable.withString(book.testament),
          Variable.withInt(book.position),
        ],
      );
    }
  }

  Future<void> _seedVersions() async {
    await customInsert(
      'INSERT OR IGNORE INTO bible_versions (id, name, abbreviation, language, copyright, is_downloaded) VALUES (?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString('rv1960'),
        Variable.withString('Reina Valera 1960'),
        Variable.withString('RV60'),
        Variable.withString('es'),
        Variable.withString('Dominio público'),
        Variable.withInt(1),
      ],
    );
  }

  Future<void> _seedReadingPlans() async {
    await customInsert(
      'INSERT OR IGNORE INTO reading_plans (id, name, description, duration_days) VALUES (1, ?, ?, ?)',
      variables: [
        Variable.withString('La Biblia en un Año'),
        Variable.withString('Lee toda la Biblia en 365 días'),
        Variable.withInt(365),
      ],
    );
    await customInsert(
      'INSERT OR IGNORE INTO reading_plans (id, name, description, duration_days) VALUES (2, ?, ?, ?)',
      variables: [
        Variable.withString('Los Evangelios en 30 Días'),
        Variable.withString('Mateo, Marcos, Lucas y Juan en 30 días'),
        Variable.withInt(30),
      ],
    );
    await customInsert(
      'INSERT OR IGNORE INTO reading_plans (id, name, description, duration_days) VALUES (3, ?, ?, ?)',
      variables: [
        Variable.withString('Nuevo Testamento en 90 Días'),
        Variable.withString('Lee todo el NT en 90 días'),
        Variable.withInt(90),
      ],
    );
  }

  Future<void> _createFtsIndex() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS verses_fts USING fts5(
        content, content='verses', content_rowid='id',
        tokenize='unicode61 remove_diacritics 2'
      )
    ''');
    await customStatement(
      "INSERT INTO verses_fts(verses_fts) VALUES('rebuild')",
    );
  }

  Future<List<Map<String, dynamic>>> searchFts(
    String query, {
    String? versionId,
  }) async {
    final terms = query.split(' ').where((w) => w.isNotEmpty).toList();
    if (terms.isEmpty) return [];

    final ftsQuery = terms.length == 1
        ? terms.first
        : terms.map((w) => '"$w"').join(' AND ');

    final sql =
        '''
      SELECT v.* FROM verses v
      INNER JOIN verses_fts fts ON v.id = fts.rowid
      WHERE verses_fts MATCH ?
      ${versionId != null ? "AND v.version_id = ?" : ""}
      ORDER BY rank
      LIMIT 100
    ''';
    final args = [ftsQuery, if (versionId != null) versionId];
    final result = await customSelect(
      sql,
      variables: args.map(Variable.withString).toList(),
    ).get();
    return result.map((r) => r.data).toList();
  }

  Future<List<Map<String, dynamic>>> searchByText(
    String text, {
    String? versionId,
  }) async {
    final like = '%$text%';
    final sql =
        '''
      SELECT * FROM verses
      WHERE content LIKE ?
      ${versionId != null ? "AND version_id = ?" : ""}
      ORDER BY book_id, chapter, verse
      LIMIT 100
    ''';
    final args = [like, if (versionId != null) versionId];
    final result = await customSelect(
      sql,
      variables: args.map(Variable.withString).toList(),
    ).get();
    return result.map((r) => r.data).toList();
  }

  Future<List<Map<String, dynamic>>> getChapterVerses(
    String versionId,
    int bookId,
    int chapter,
  ) async {
    final result = await customSelect(
      'SELECT * FROM verses WHERE version_id = ? AND book_id = ? AND chapter = ? ORDER BY verse',
      variables: [
        Variable.withString(versionId),
        Variable.withInt(bookId),
        Variable.withInt(chapter),
      ],
    ).get();
    return result.map((r) => r.data).toList();
  }

  Future<Map<String, dynamic>?> getDailyVerse(String versionId) async {
    final versionId0 = versionId;
    final countRes = await customSelect(
      'SELECT COUNT(*) as c FROM verses WHERE version_id = ?',
      variables: [Variable.withString(versionId0)],
    ).getSingle();
    final count = countRes.data['c'] as int;
    if (count == 0) return null;
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(start).inDays;
    final offset = dayOfYear % count;
    final res = await customSelect(
      'SELECT * FROM verses WHERE version_id = ? ORDER BY book_id, chapter, verse LIMIT 1 OFFSET ?',
      variables: [Variable.withString(versionId0), Variable.withInt(offset)],
    ).get();
    if (res.isEmpty) return null;
    return res.first.data;
  }

  // ---- Bookmark folders ----
  Future<List<Map<String, dynamic>>> getBookmarkFolders() async {
    final result = await customSelect(
      'SELECT * FROM bookmark_folders ORDER BY created_at',
    ).get();
    return result.map((r) => r.data).toList();
  }

  Future<int> createBookmarkFolder(String name, String color) async {
    return await customInsert(
      'INSERT INTO bookmark_folders (name, color, created_at) VALUES (?, ?, ?)',
      variables: [
        Variable.withString(name),
        Variable.withString(color),
        Variable.withDateTime(DateTime.now()),
      ],
    );
  }

  Future<void> deleteBookmarkFolder(int id) async {
    await customUpdate(
      'UPDATE bookmarks SET folder_id = NULL WHERE folder_id = ?',
      variables: [Variable.withInt(id)],
    );
    await customUpdate(
      'DELETE FROM bookmark_folders WHERE id = ?',
      variables: [Variable.withInt(id)],
    );
  }

  Future<void> setBookmarkFolder(int bookmarkId, int? folderId) async {
    if (folderId == null) {
      await customUpdate(
        'UPDATE bookmarks SET folder_id = NULL WHERE id = ?',
        variables: [Variable.withInt(bookmarkId)],
      );
    } else {
      await customUpdate(
        'UPDATE bookmarks SET folder_id = ? WHERE id = ?',
        variables: [Variable.withInt(folderId), Variable.withInt(bookmarkId)],
      );
    }
  }

  // ---- Search history ----
  Future<void> addSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    await customInsert(
      'INSERT INTO search_history (query, created_at) VALUES (?, ?)',
      variables: [
        Variable.withString(query.trim()),
        Variable.withDateTime(DateTime.now()),
      ],
    );
    await customUpdate(
      'DELETE FROM search_history WHERE id NOT IN (SELECT id FROM search_history ORDER BY created_at DESC LIMIT 20)',
    );
  }

  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final result = await customSelect(
      'SELECT query FROM search_history GROUP BY query ORDER BY MAX(created_at) DESC LIMIT 20',
    ).get();
    return result.map((r) => r.data).toList();
  }

  Future<void> clearSearchHistory() async {
    await customUpdate('DELETE FROM search_history');
  }

  // ---- Reading log / streak ----
  Future<void> logReading(
    String versionId,
    int bookId,
    int chapter,
    int versesRead,
  ) async {
    final day = _todayKey();
    await customInsert(
      'INSERT INTO reading_log (day, version_id, book_id, chapter, verses_read) VALUES (?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(day),
        Variable.withString(versionId),
        Variable.withInt(bookId),
        Variable.withInt(chapter),
        Variable.withInt(versesRead),
      ],
    );
  }

  Future<int> getReadingStreak() async {
    final rows = await customSelect(
      'SELECT DISTINCT day FROM reading_log ORDER BY day DESC',
    ).get();
    final days = rows.map((r) => r.data['day'] as String).toList();
    if (days.isEmpty) return 0;
    int streak = 0;
    var expected = DateTime.now();
    for (final d in days) {
      final date = DateTime.tryParse(d);
      if (date == null) continue;
      if (!_sameDay(date, expected)) break;
      streak++;
      expected = expected.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<int> getVersesReadToday() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(verses_read), 0) as total FROM reading_log WHERE day = ?',
      variables: [Variable.withString(_todayKey())],
    ).getSingle();
    return result.data['total'] as int;
  }

  // ---- Note tags ----
  Future<void> setNoteTags(int noteId, List<String> tags) async {
    await customUpdate(
      'DELETE FROM note_tags WHERE note_id = ?',
      variables: [Variable.withInt(noteId)],
    );
    for (final tag in tags) {
      await customInsert(
        'INSERT INTO note_tags (note_id, tag) VALUES (?, ?)',
        variables: [Variable.withInt(noteId), Variable.withString(tag)],
      );
    }
  }

  Future<List<String>> getNoteTags(int noteId) async {
    final result = await customSelect(
      'SELECT tag FROM note_tags WHERE note_id = ?',
      variables: [Variable.withInt(noteId)],
    ).get();
    return result.map((r) => r.data['tag'] as String).toList();
  }

  Future<List<String>> getAllNoteTags() async {
    final result = await customSelect(
      'SELECT DISTINCT tag FROM note_tags ORDER BY tag',
    ).get();
    return result.map((r) => r.data['tag'] as String).toList();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
