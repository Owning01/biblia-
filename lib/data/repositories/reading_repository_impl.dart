import 'package:drift/drift.dart' hide Column;
import '../../core/database/app_database.dart';
import '../../domain/repositories/reading_repository.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  final AppDatabase _db;

  ReadingRepositoryImpl(this._db);

  @override
  Future<List<Map<String, dynamic>>> getPlans() async {
    final rows = await _db.customSelect('SELECT * FROM reading_plans').get();
    return rows.map((r) => r.data).toList();
  }

  @override
  Future<Set<int>> getProgress(int planId) async {
    final rows = await _db
        .customSelect(
          'SELECT day FROM reading_progress WHERE plan_id = ? AND completed = 1',
          variables: [Variable.withInt(planId)],
        )
        .get();
    return rows.map((r) => r.data['day'] as int).toSet();
  }

  @override
  Future<Map<String, dynamic>?> getPlanDay(int planId, int day) async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM reading_plan_days WHERE plan_id = ? AND day = ?',
          variables: [Variable.withInt(planId), Variable.withInt(day)],
        )
        .get();
    if (rows.isEmpty) return null;
    return rows.first.data;
  }

  @override
  Future<void> markDay(int planId, int day, bool completed) async {
    if (completed) {
      await _db.customInsert(
        'INSERT OR REPLACE INTO reading_progress (plan_id, day, completed, completed_at) VALUES (?, ?, 1, ?)',
        variables: [
          Variable.withInt(planId),
          Variable.withInt(day),
          Variable.withString(DateTime.now().toIso8601String()),
        ],
      );
    } else {
      await _db.customUpdate(
        'DELETE FROM reading_progress WHERE plan_id = ? AND day = ?',
        variables: [Variable.withInt(planId), Variable.withInt(day)],
      );
    }
  }

  @override
  Future<void> logReading(
    String versionId,
    int bookId,
    int chapter,
    int versesRead,
  ) async {
    await _db.logReading(versionId, bookId, chapter, versesRead);
  }

  @override
  Future<int> getReadingStreak() async {
    return _db.getReadingStreak();
  }

  @override
  Future<int> getVersesReadToday() async {
    return _db.getVersesReadToday();
  }

  @override
  Future<int> createPlan(
    String name,
    String description,
    int durationDays,
  ) async {
    return await _db.customInsert(
      'INSERT INTO reading_plans (name, description, duration_days) VALUES (?, ?, ?)',
      variables: [
        Variable.withString(name),
        Variable.withString(description),
        Variable.withInt(durationDays),
      ],
    );
  }

  @override
  Future<void> addPlanDay(
    int planId,
    int day,
    String versionId,
    int bookId,
    int chapter, {
    int verseStart = 1,
    int? verseEnd,
  }) async {
    await _db.customInsert(
      'INSERT INTO reading_plan_days (plan_id, day, version_id, book_id, chapter, verse_start, verse_end) VALUES (?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withInt(planId),
        Variable.withInt(day),
        Variable.withString(versionId),
        Variable.withInt(bookId),
        Variable.withInt(chapter),
        Variable.withInt(verseStart),
        Variable.withInt(verseEnd ?? 0),
      ],
    );
  }
}
