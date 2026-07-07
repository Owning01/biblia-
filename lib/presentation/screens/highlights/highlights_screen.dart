import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants/bible_metadata.dart';
import '../../../core/database/app_database.dart';
import '../../providers/user_data_providers.dart';

class HighlightsScreen extends ConsumerWidget {
  const HighlightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightsAsync = ref.watch(highlightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subrayados')),
      body: highlightsAsync.when(
        data: (highlights) {
          if (highlights.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes subrayados',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: highlights.length,
            itemBuilder: (context, index) {
              final h = highlights[index];
              final book = booksById[h.bookId];
              final refText =
                  '${book?.name ?? ''} ${h.chapter}:${h.verseStart}';
              final color = Color(int.parse(h.color.replaceFirst('#', '0xFF')));

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(
                    h.verseText != null ? h.verseText! : refText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    refText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _removeHighlight(ref, h.id),
                  ),
                  onTap: () => context.push(
                    '/read/${h.versionId}/${h.bookId}/${h.chapter}',
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _removeHighlight(WidgetRef ref, int id) async {
    final db = ref.read(appDatabaseProvider);
    await db.customInsert(
      'DELETE FROM highlights WHERE id = ?',
      variables: [Variable.withInt(id)],
    );
    ref.invalidate(highlightsProvider);
  }
}
