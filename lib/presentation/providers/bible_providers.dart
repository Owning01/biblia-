import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/verse.dart';
import 'settings_providers.dart';

final booksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getBooks();
});

final chapterVersesProvider =
    FutureProvider.family<
      List<Verse>,
      ({String versionId, int bookId, int chapter})
    >((ref, params) async {
      final repo = ref.watch(bibleRepositoryProvider);
      return repo.getChapterVerses(
        params.versionId,
        params.bookId,
        params.chapter,
      );
    });

final verseProvider =
    FutureProvider.family<
      Verse?,
      ({String versionId, int bookId, int chapter, int verse})
    >((ref, params) async {
      final repo = ref.watch(bibleRepositoryProvider);
      return repo.getSingleVerse(
        params.versionId,
        params.bookId,
        params.chapter,
        params.verse,
      );
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
