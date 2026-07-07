import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/app_database.dart' hide Verse;
import '../../domain/entities/verse.dart';
import 'settings_providers.dart';

final booksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db.customSelect('SELECT * FROM books ORDER BY id').get();
  return rows.map((r) => r.data).toList();
});

final chapterVersesProvider =
    FutureProvider.family<
      List<Verse>,
      ({String versionId, int bookId, int chapter})
    >((ref, params) async {
      final db = ref.watch(appDatabaseProvider);
      final rows = await db.getChapterVerses(
        params.versionId,
        params.bookId,
        params.chapter,
      );
      return rows.map(Verse.fromMap).toList();
    });

final verseProvider =
    FutureProvider.family<
      Verse?,
      ({String versionId, int bookId, int chapter, int verse})
    >((ref, params) async {
      final db = ref.watch(appDatabaseProvider);
      final result = await db
          .customSelect(
            'SELECT * FROM verses WHERE version_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
            variables: [
              Variable.withString(params.versionId),
              Variable.withInt(params.bookId),
              Variable.withInt(params.chapter),
              Variable.withInt(params.verse),
            ],
          )
          .get();
      if (result.isEmpty) return null;
      return Verse.fromMap(result.first.data);
    });

final lastReadProvider =
    StateProvider<({String versionId, int bookId, int chapter})?>(
      (ref) => null,
    );

final lastReadByBookProvider =
    StateNotifierProvider<LastReadByBookNotifier, Map<String, int>>((ref) {
      return LastReadByBookNotifier(ref);
    });

class LastReadByBookNotifier extends StateNotifier<Map<String, int>> {
  final Ref _ref;

  LastReadByBookNotifier(this._ref) : super({}) {
    _load();
  }

  void _load() {
    final prefs = _ref.read(sharedPrefsProvider);
    final raw = prefs.getString('last_read_by_book');
    if (raw != null) {
      state = Map<String, int>.from(jsonDecode(raw) as Map);
    }
  }

  void setLastChapter(int bookId, int chapter) {
    state = {...state, bookId.toString(): chapter};
    final prefs = _ref.read(sharedPrefsProvider);
    prefs.setString('last_read_by_book', jsonEncode(state));
  }

  int getLastChapter(int bookId) {
    return state[bookId.toString()] ?? 1;
  }
}
