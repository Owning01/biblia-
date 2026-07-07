import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/verse.dart';
import 'settings_providers.dart';
import 'user_data_providers.dart';

final dailyVerseProvider = FutureProvider<Verse?>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final versionId = ref.watch(activeVersionProvider);
  return repo.getDailyVerse(versionId);
});

final readingStreakProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(readingRepositoryProvider);
  return repo.getReadingStreak();
});

final versesReadTodayProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(readingRepositoryProvider);
  return repo.getVersesReadToday();
});

final bookmarkFoldersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.getBookmarkFolders();
});

final searchHistoryProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(userDataRepositoryProvider);
  final rows = await repo.getSearchHistory();
  return rows.map((r) => r['query'] as String).toList();
});

final allNoteTagsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.getAllNoteTags();
});

class BookmarkFolderActions {
  final WidgetRef ref;
  BookmarkFolderActions(this.ref);

  Future<void> create(String name, String color) async {
    final repo = ref.read(userDataRepositoryProvider);
    await repo.createBookmarkFolder(name, color);
    ref.invalidate(bookmarkFoldersProvider);
    ref.invalidate(bookmarksProvider);
  }

  Future<void> delete(int id) async {
    final repo = ref.read(userDataRepositoryProvider);
    await repo.deleteBookmarkFolder(id);
    ref.invalidate(bookmarkFoldersProvider);
    ref.invalidate(bookmarksProvider);
  }
}

class SearchHistoryActions {
  final WidgetRef ref;
  SearchHistoryActions(this.ref);

  Future<void> add(String query) async {
    final repo = ref.read(userDataRepositoryProvider);
    await repo.addSearchHistory(query);
    ref.invalidate(searchHistoryProvider);
  }

  Future<void> clear() async {
    final repo = ref.read(userDataRepositoryProvider);
    await repo.clearSearchHistory();
    ref.invalidate(searchHistoryProvider);
  }
}
