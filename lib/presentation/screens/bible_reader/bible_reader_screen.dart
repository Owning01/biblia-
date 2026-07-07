import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants/bible_metadata.dart';
import '../../../core/database/app_database.dart' hide Verse;
import '../../../core/utils/verse_image_generator.dart';
import '../../../domain/entities/verse.dart';
import '../../providers/bible_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/user_data_providers.dart';
import '../../providers/extra_providers.dart';
import '../../shared/reading_config_sheet.dart';
import '../../shared/verse_actions_sheet.dart';
import '../../shared/verse_tile.dart';

class BibleReaderScreen extends ConsumerStatefulWidget {
  final String versionId;
  final int bookId;
  final int chapter;

  const BibleReaderScreen({
    super.key,
    required this.versionId,
    required this.bookId,
    required this.chapter,
  });

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  late final PageController _pageController;
  late int _currentChapter;
  final Set<(int, int)> _logged = {};

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _pageController = PageController(initialPage: _currentChapter - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLastRead());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateLastRead() {
    ref.read(lastReadProvider.notifier).state = (
      versionId: widget.versionId,
      bookId: widget.bookId,
      chapter: _currentChapter,
    );
    ref
        .read(lastReadByBookProvider.notifier)
        .setLastChapter(widget.bookId, _currentChapter);
    _logReading();
  }

  Future<void> _logReading() async {
    final key = (widget.bookId, _currentChapter);
    if (!_logged.add(key)) return;
    final db = ref.read(appDatabaseProvider);
    final count = await db
        .customSelect(
          'SELECT COUNT(*) as c FROM verses WHERE version_id = ? AND book_id = ? AND chapter = ?',
          variables: [
            Variable.withString(widget.versionId),
            Variable.withInt(widget.bookId),
            Variable.withInt(_currentChapter),
          ],
        )
        .getSingle();
    final verses = (count.data['c'] as int?) ?? 0;
    if (verses > 0) {
      await db.logReading(
        widget.versionId,
        widget.bookId,
        _currentChapter,
        verses,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = booksById[widget.bookId];
    final chapterCount = bookChapterCounts[widget.bookId] ?? 1;
    final fontSize = ref.watch(fontSizeProvider);
    final fontFamily = ref.watch(fontFamilyProvider);
    final margin = ref.watch(readingMarginProvider);
    final verseSpacing = ref.watch(verseSpacingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${book?.name ?? ''} $_currentChapter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notes_outlined),
            onPressed: () => context.push('/notes'),
          ),
          IconButton(
            icon: const Icon(Icons.highlight_outlined),
            onPressed: () => context.push('/highlights'),
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Configuracion de lectura',
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const ReadingConfigSheet(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: chapterCount,
              onPageChanged: (page) {
                setState(() => _currentChapter = page + 1);
                _updateLastRead();
              },
              itemBuilder: (context, page) {
                final ch = page + 1;
                return _ChapterContent(
                  versionId: widget.versionId,
                  bookId: widget.bookId,
                  chapter: ch,
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                  margin: margin,
                  verseSpacing: verseSpacing,
                  onVerseTap: (v) => _showVerseActions(v),
                );
              },
            ),
          ),
          _ChapterNavigator(
            currentChapter: _currentChapter,
            chapterCount: chapterCount,
            onChanged: (chapter) {
              _pageController.animateToPage(
                chapter - 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showVerseActions(Verse v) {
    final highlights = ref.read(highlightsProvider).valueOrNull ?? [];
    final currentHighlight = highlights.where(
      (h) =>
          h.versionId == widget.versionId &&
          h.bookId == widget.bookId &&
          h.chapter == _currentChapter &&
          h.verseStart == v.verse,
    );
    final existingColor = currentHighlight.isNotEmpty
        ? currentHighlight.first.color
        : null;

    ref
        .read(
          bookmarkStatusProvider((
            versionId: widget.versionId,
            bookId: widget.bookId,
            chapter: _currentChapter,
            verse: v.verse,
          )),
        )
        .whenData((isBookmarked) {
          if (!context.mounted) return;
          showModalBottomSheet(
            context: context,
            builder: (ctx) => VerseActionsSheet(
              verse: v,
              isBookmarked: isBookmarked,
              highlightColor: existingColor,
              onBookmark: () => _toggleBookmark(v),
              onHighlight: (color, category) =>
                  _toggleHighlight(v, color, category),
              onNote: () => _addNote(v),
              onShare: () => _shareText(v),
              onShareImage: () => _shareImage(v),
              onCompare: () => _showCompare(v),
            ),
          );
        });
  }

  void _toggleBookmark(Verse v) async {
    final db = ref.read(appDatabaseProvider);
    final existing = await db
        .customSelect(
          'SELECT id FROM bookmarks WHERE version_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
          variables: [
            Variable.withString(widget.versionId),
            Variable.withInt(widget.bookId),
            Variable.withInt(_currentChapter),
            Variable.withInt(v.verse),
          ],
        )
        .get();

    if (existing.isNotEmpty) {
      await db.customInsert(
        'DELETE FROM bookmarks WHERE id = ?',
        variables: [Variable.withInt(existing.first.data['id'] as int)],
      );
    } else {
      await db.customInsert(
        'INSERT INTO bookmarks (version_id, book_id, chapter, verse, created_at) VALUES (?, ?, ?, ?, ?)',
        variables: [
          Variable.withString(widget.versionId),
          Variable.withInt(widget.bookId),
          Variable.withInt(_currentChapter),
          Variable.withInt(v.verse),
          Variable.withString(DateTime.now().toIso8601String()),
        ],
      );
    }
    ref.invalidate(bookmarkStatusProvider);
    ref.invalidate(bookmarksProvider);
    if (context.mounted) Navigator.pop(context);
  }

  void _toggleHighlight(Verse v, String color, String? category) async {
    final db = ref.read(appDatabaseProvider);
    if (color.isEmpty) {
      await db.customInsert(
        'DELETE FROM highlights WHERE version_id = ? AND book_id = ? AND chapter = ? AND verse_start = ?',
        variables: [
          Variable.withString(widget.versionId),
          Variable.withInt(widget.bookId),
          Variable.withInt(_currentChapter),
          Variable.withInt(v.verse),
        ],
      );
    } else {
      await db.customInsert(
        'INSERT INTO highlights (version_id, book_id, chapter, verse_start, verse_end, color, category, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        variables: [
          Variable.withString(widget.versionId),
          Variable.withInt(widget.bookId),
          Variable.withInt(_currentChapter),
          Variable.withInt(v.verse),
          Variable.withInt(v.verse),
          Variable.withString(color),
          Variable.withString(category ?? ''),
          Variable.withString(DateTime.now().toIso8601String()),
        ],
      );
    }
    ref.invalidate(highlightsProvider);
    if (context.mounted) Navigator.pop(context);
  }

  void _addNote(Verse v) async {
    Navigator.pop(context);
    final controller = TextEditingController();
    final tagController = TextEditingController();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Nota - ${booksById[widget.bookId]?.name ?? ''} $_currentChapter:${v.verse}',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Escribe tu nota...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                hintText: 'Etiquetas (separadas por coma)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, (controller.text, tagController.text)),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && result.$1.isNotEmpty) {
      final db = ref.read(appDatabaseProvider);
      final now = DateTime.now().toIso8601String();
      final id = await db.customInsert(
        'INSERT INTO notes (version_id, book_id, chapter, verse, content, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
        variables: [
          Variable.withString(widget.versionId),
          Variable.withInt(widget.bookId),
          Variable.withInt(_currentChapter),
          Variable.withInt(v.verse),
          Variable.withString(result.$1),
          Variable.withString(now),
          Variable.withString(now),
        ],
      );
      final tags = result.$2
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (tags.isNotEmpty) await db.setNoteTags(id, tags);
      ref.invalidate(notesProvider);
      ref.invalidate(allNoteTagsProvider);
    }
  }

  void _shareText(Verse v) {
    Navigator.pop(context);
    final book = booksById[widget.bookId];
    final refText = '${book?.name ?? ''} $_currentChapter:${v.verse}';
    final text = '"${v.text}"\n\n- $refText (Biblia)';
    Share.share(text);
  }

  void _showCompare(Verse v) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CompareSheet(
        bookId: widget.bookId,
        chapter: _currentChapter,
        verse: v.verse,
      ),
    );
  }

  void _shareImage(Verse v) async {
    Navigator.pop(context);
    final book = booksById[widget.bookId];
    final refText = '${book?.name ?? ''} $_currentChapter:${v.verse}';

    final imageBytes = await VerseImageGenerator.generate(
      verseText: v.text,
      reference: refText,
      fontSize: 28,
    );

    if (imageBytes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al generar la imagen')),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/verse_${widget.bookId}_$_currentChapter.png';
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles([XFile(filePath)]);
  }
}

class _CompareSheet extends ConsumerStatefulWidget {
  final int bookId;
  final int chapter;
  final int verse;

  const _CompareSheet({
    required this.bookId,
    required this.chapter,
    required this.verse,
  });

  @override
  ConsumerState<_CompareSheet> createState() => _CompareSheetState();
}

class _CompareSheetState extends ConsumerState<_CompareSheet> {
  late Future<List<QueryRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<QueryRow>> _fetch() {
    final db = ref.read(appDatabaseProvider);
    return db
        .customSelect(
          'SELECT v.content AS text, bv.name AS version_name FROM verses v '
          'JOIN bible_versions bv ON bv.id = v.version_id '
          'WHERE v.book_id = ? AND v.chapter = ? AND v.verse = ? '
          'ORDER BY bv.id',
          variables: [
            Variable.withInt(widget.bookId),
            Variable.withInt(widget.chapter),
            Variable.withInt(widget.verse),
          ],
        )
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = booksById[widget.bookId];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scroll) => FutureBuilder<List<QueryRow>>(
        future: _future,
        builder: (context, snap) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${book?.name ?? ''} ${widget.chapter}:${widget.verse}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final rows = snap.data!;
                    if (rows.isEmpty) {
                      return const Center(
                        child: Text('No hay versiones disponibles'),
                      );
                    }
                    return ListView.separated(
                      controller: scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final r = rows[i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.data['version_name'] as String,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              (r.data['text'] as String?) ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChapterContent extends ConsumerWidget {
  final String versionId;
  final int bookId;
  final int chapter;
  final double fontSize;
  final String fontFamily;
  final double margin;
  final double verseSpacing;
  final void Function(Verse) onVerseTap;

  const _ChapterContent({
    required this.versionId,
    required this.bookId,
    required this.chapter,
    required this.fontSize,
    required this.fontFamily,
    required this.margin,
    required this.verseSpacing,
    required this.onVerseTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versesAsync = ref.watch(
      chapterVersesProvider((
        versionId: versionId,
        bookId: bookId,
        chapter: chapter,
      )),
    );
    final highlightsAsync = ref.watch(highlightsProvider);

    return versesAsync.when(
      data: (verses) {
        if (verses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay versiculos disponibles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los datos biblicos aun no han sido cargados.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final highlighted = highlightsAsync.valueOrNull ?? [];
        final colors = <int, String>{};
        for (final h in highlighted) {
          if (h.bookId == bookId && h.chapter == chapter) {
            for (var v = h.verseStart; v <= h.verseEnd; v++) {
              colors[v] = h.color;
            }
          }
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: verses.length,
          separatorBuilder: (_, __) => SizedBox(height: verseSpacing),
          itemBuilder: (context, index) {
            final verse = verses[index];
            return VerseTile(
              verse: verse,
              highlightColor: colors[verse.verse],
              fontSize: fontSize,
              fontFamily: fontFamily,
              margin: margin,
              onTap: onVerseTap,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ChapterNavigator extends StatelessWidget {
  final int currentChapter;
  final int chapterCount;
  final void Function(int chapter) onChanged;

  const _ChapterNavigator({
    required this.currentChapter,
    required this.chapterCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentChapter > 1
                ? () => onChanged(currentChapter - 1)
                : null,
          ),
          Text('$currentChapter / $chapterCount'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentChapter < chapterCount
                ? () => onChanged(currentChapter + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
