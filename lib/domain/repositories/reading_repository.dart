abstract class ReadingRepository {
  Future<List<Map<String, dynamic>>> getPlans();
  Future<Set<int>> getProgress(int planId);
  Future<Map<String, dynamic>?> getPlanDay(int planId, int day);
  Future<void> markDay(int planId, int day, bool completed);
  Future<void> logReading(
    String versionId,
    int bookId,
    int chapter,
    int versesRead,
  );
  Future<int> getReadingStreak();
  Future<int> getVersesReadToday();
  Future<int> createPlan(String name, String description, int durationDays);
  Future<void> addPlanDay(
    int planId,
    int day,
    String versionId,
    int bookId,
    int chapter, {
    int verseStart = 1,
    int? verseEnd,
  });
}
