import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/bible_metadata.dart';
import '../../providers/settings_providers.dart';

class BookSelectorScreen extends ConsumerWidget {
  final int? initialBookId;

  const BookSelectorScreen({super.key, this.initialBookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeVersion = ref.watch(activeVersionProvider);

    if (initialBookId != null) {
      return _ChapterGridScreen(
        bookId: initialBookId!,
        versionId: activeVersion,
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Libros'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'AT'),
              Tab(text: 'NT'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookList(testament: 'old', versionId: activeVersion),
            _BookList(testament: 'new', versionId: activeVersion),
          ],
        ),
      ),
    );
  }
}

class _BookList extends ConsumerWidget {
  final String testament;
  final String versionId;

  const _BookList({required this.testament, required this.versionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = bibleBooks.where((b) => b.testament == testament).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = filtered[index];
        final count = bookChapterCounts[book.id] ?? 1;
        return ListTile(
          title: Text(
            book.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text('$count capítulos'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/read/$versionId/${book.id}/1'),
        );
      },
    );
  }
}

class _ChapterGridScreen extends ConsumerWidget {
  final int bookId;
  final String versionId;

  const _ChapterGridScreen({required this.bookId, required this.versionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = booksById[bookId];
    final count = bookChapterCounts[bookId] ?? 1;
    final summary = bookSummaries[bookId];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(book?.name ?? '')),
      body: CustomScrollView(
        slivers: [
          if (summary != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Resumen',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final chapter = index + 1;
                return FilledButton.tonal(
                  onPressed: () =>
                      context.push('/read/$versionId/$bookId/$chapter'),
                  child: Text('$chapter'),
                );
              }, childCount: count),
            ),
          ),
        ],
      ),
    );
  }
}
