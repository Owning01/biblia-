import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/app_database.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/user_data.dart' as domain;

final bookmarksProvider = FutureProvider<List<domain.Bookmark>>((ref) async {
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.getBookmarks();
});

final bookmarkStatusProvider =
    FutureProvider.family<
      bool,
      ({String versionId, int bookId, int chapter, int verse})
    >((ref, params) async {
      final repo = ref.watch(userDataRepositoryProvider);
      return repo.bookmarkExists(
        params.versionId,
        params.bookId,
        params.chapter,
        params.verse,
      );
    });

final highlightsProvider = FutureProvider<List<domain.Highlight>>((ref) async {
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.getHighlights();
});

final notesProvider = FutureProvider<List<domain.Note>>((ref) async {
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.getNotes();
});

final readingPlansProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(readingRepositoryProvider);
  return repo.getPlans();
});

final readingProgressProvider = FutureProvider.family<Set<int>, int>((
  ref,
  planId,
) async {
  final repo = ref.watch(readingRepositoryProvider);
  return repo.getProgress(planId);
});

final readingPlanDayProvider =
    FutureProvider.family<Map<String, dynamic>?, ({int planId, int day})>((
      ref,
      params,
    ) async {
      final repo = ref.watch(readingRepositoryProvider);
      return repo.getPlanDay(params.planId, params.day);
    });

final prayerRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db
      .customSelect('SELECT * FROM prayer_requests ORDER BY created_at DESC')
      .get();
  return rows.map((r) => r.data).toList();
});

final hasPrayedProvider =
    FutureProvider.family<bool, ({int requestId, String userName})>((
      ref,
      params,
    ) async {
      final db = ref.watch(appDatabaseProvider);
      final result = await db
          .customSelect(
            'SELECT id FROM prayer_actions WHERE request_id = ? AND user_name = ?',
            variables: [
              Variable.withInt(params.requestId),
              Variable.withString(params.userName),
            ],
          )
          .get();
      return result.isNotEmpty;
    });

final noteTagsMapProvider = FutureProvider<Map<int, List<String>>>((ref) async {
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.getNoteTagsMap();
});
