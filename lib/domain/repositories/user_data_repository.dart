import '../entities/user_data.dart';

abstract class UserDataRepository {
  // Bookmarks
  Future<List<Bookmark>> getBookmarks();
  Future<bool> bookmarkExists(
    String versionId,
    int bookId,
    int chapter,
    int verse,
  );
  Future<void> toggleBookmark(
    String versionId,
    int bookId,
    int chapter,
    int verse,
  );
  Future<void> deleteBookmark(int id);
  Future<void> setBookmarkFolder(int bookmarkId, int? folderId);

  // Folders
  Future<List<Map<String, dynamic>>> getBookmarkFolders();
  Future<int> createBookmarkFolder(String name, String color);
  Future<void> deleteBookmarkFolder(int id);

  // Highlights
  Future<List<Highlight>> getHighlights();
  Future<void> toggleHighlight(
    String versionId,
    int bookId,
    int chapter,
    int verse,
    String color,
    String? category,
  );

  // Notes
  Future<List<Note>> getNotes();
  Future<int> createNote(
    String versionId,
    int bookId,
    int chapter,
    int verse,
    String content,
  );
  Future<void> updateNote(int id, String content);
  Future<void> deleteNote(int id);

  // Tags
  Future<void> setNoteTags(int noteId, List<String> tags);
  Future<List<String>> getNoteTags(int noteId);
  Future<List<String>> getAllNoteTags();
  Future<Map<int, List<String>>> getNoteTagsMap();

  // Search history
  Future<void> addSearchHistory(String query);
  Future<List<Map<String, dynamic>>> getSearchHistory();
  Future<void> clearSearchHistory();
}
