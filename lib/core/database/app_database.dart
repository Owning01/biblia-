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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedAll();
      await _createFtsIndex();
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
    final versions = [
      ('rv1960', 'Reina Valera 1960', 'RV60', 'es', 'Dominio público', 1),
      (
        'rv1995',
        'Reina Valera 1995',
        'RV95',
        'es',
        'Sociedades Bíblicas Unidas',
        0,
      ),
      ('nvi', 'Nueva Versión Internacional', 'NVI', 'es', 'Biblica Inc.', 0),
      (
        'pdt',
        'Palabra de Dios para Todos',
        'PDT',
        'es',
        'Sociedades Bíblicas Unidas',
        0,
      ),
    ];

    for (final (id, name, abbr, lang, copyright, downloaded) in versions) {
      await customInsert(
        'INSERT OR IGNORE INTO bible_versions (id, name, abbreviation, language, copyright, is_downloaded) VALUES (?, ?, ?, ?, ?, ?)',
        variables: [
          Variable.withString(id),
          Variable.withString(name),
          Variable.withString(abbr),
          Variable.withString(lang),
          Variable.withString(copyright),
          Variable.withInt(downloaded),
        ],
      );
    }
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
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
