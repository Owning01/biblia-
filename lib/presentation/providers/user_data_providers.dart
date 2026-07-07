import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../domain/entities/user_data.dart' as domain;

final bookmarksProvider = FutureProvider<List<domain.Bookmark>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db
      .customSelect(
        'SELECT b.*, v.content AS verse_text FROM bookmarks b LEFT JOIN verses v ON v.version_id = b.version_id AND v.book_id = b.book_id AND v.chapter = b.chapter AND v.verse = b.verse ORDER BY b.created_at DESC',
      )
      .get();
  return rows.map((r) => domain.Bookmark.fromMap(r.data)).toList();
});

final bookmarkStatusProvider =
    FutureProvider.family<
      bool,
      ({String versionId, int bookId, int chapter, int verse})
    >((ref, params) async {
      final db = ref.watch(appDatabaseProvider);
      final result = await db
          .customSelect(
            'SELECT id FROM bookmarks WHERE version_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
            variables: [
              Variable.withString(params.versionId),
              Variable.withInt(params.bookId),
              Variable.withInt(params.chapter),
              Variable.withInt(params.verse),
            ],
          )
          .get();
      return result.isNotEmpty;
    });

final highlightsProvider = FutureProvider<List<domain.Highlight>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db
      .customSelect(
        'SELECT h.*, v.content AS verse_text FROM highlights h LEFT JOIN verses v ON v.version_id = h.version_id AND v.book_id = h.book_id AND v.chapter = h.chapter AND v.verse = h.verse_start ORDER BY h.created_at DESC',
      )
      .get();
  return rows.map((r) => domain.Highlight.fromMap(r.data)).toList();
});

final notesProvider = FutureProvider<List<domain.Note>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db
      .customSelect('SELECT * FROM notes ORDER BY created_at DESC')
      .get();
  return rows.map((r) => domain.Note.fromMap(r.data)).toList();
});

final readingPlansProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db.customSelect('SELECT * FROM reading_plans').get();
  return rows.map((r) => r.data).toList();
});

final readingProgressProvider = FutureProvider.family<Set<int>, int>((
  ref,
  planId,
) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db
      .customSelect(
        'SELECT day FROM reading_progress WHERE plan_id = ? AND completed = 1',
        variables: [Variable.withInt(planId)],
      )
      .get();
  return rows.map((r) => r.data['day'] as int).toSet();
});

final readingPlanDayProvider =
    FutureProvider.family<Map<String, dynamic>?, ({int planId, int day})>((
      ref,
      params,
    ) async {
      final db = ref.watch(appDatabaseProvider);
      final rows = await db
          .customSelect(
            'SELECT * FROM reading_plan_days WHERE plan_id = ? AND day = ?',
            variables: [
              Variable.withInt(params.planId),
              Variable.withInt(params.day),
            ],
          )
          .get();
      if (rows.isEmpty) return null;
      return rows.first.data;
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
