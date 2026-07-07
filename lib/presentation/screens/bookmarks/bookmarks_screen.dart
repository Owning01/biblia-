import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants/bible_metadata.dart';
import '../../../core/database/app_database.dart';
import '../../../domain/entities/user_data.dart' as domain;
import '../../providers/user_data_providers.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Marcadores')),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes marcadores',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca el icono de marcador al leer un versiculo para guardarlo aqui',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          final grouped = <String, List<domain.Bookmark>>{};
          for (final b in bookmarks) {
            final book = booksById[b.bookId];
            final key = '${book?.name ?? ''} ${b.chapter}';
            grouped.putIfAbsent(key, () => []);
            grouped[key]!.add(b);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    ...entry.value.map((bookmark) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          bookmark.verseText != null
                              ? bookmark.verseText!
                              : 'Versiculo ${bookmark.verse}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          timeago.format(bookmark.createdAt, locale: 'es'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _removeBookmark(ref, bookmark),
                        ),
                        onTap: () => context.push(
                          '/read/${bookmark.versionId}/${bookmark.bookId}/${bookmark.chapter}',
                        ),
                      );
                    }),
                  ],
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _removeBookmark(WidgetRef ref, domain.Bookmark bookmark) async {
    final db = ref.read(appDatabaseProvider);
    await db.customInsert(
      'DELETE FROM bookmarks WHERE id = ?',
      variables: [Variable.withInt(bookmark.id)],
    );
    ref.invalidate(bookmarksProvider);
  }
}
