import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:drift/drift.dart' hide Column;
import '../../../core/database/app_database.dart';
import '../../../domain/entities/user_data.dart' as domain;
import '../../providers/user_data_providers.dart';
import '../../providers/extra_providers.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  int? _selectedFolder;

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final foldersAsync = ref.watch(bookmarkFoldersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Marcadores')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nueva carpeta',
        onPressed: () => _createFolder(context),
        child: const Icon(Icons.create_new_folder_outlined),
      ),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          final folders = foldersAsync.value ?? [];
          final visible = bookmarks.where((b) {
            if (_selectedFolder == null) return true;
            return b.folderId == _selectedFolder;
          }).toList();

          if (bookmarks.isEmpty) {
            return _EmptyState();
          }

          return Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FolderChip(
                      label: 'Todos',
                      selected: _selectedFolder == null,
                      onTap: () => setState(() => _selectedFolder = null),
                    ),
                    ...folders.map((f) {
                      final id = f['id'] as int;
                      return _FolderChip(
                        label: f['name'] as String,
                        color: f['color'] as String,
                        selected: _selectedFolder == id,
                        onTap: () => setState(() => _selectedFolder = id),
                        onLongPress: () => _confirmDeleteFolder(context, id),
                      );
                    }),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: visible.map((bookmark) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
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
                        trailing: PopupMenuButton<String>(
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'uncategorized',
                              child: Text('Sin carpeta'),
                            ),
                            ...folders.map(
                              (f) => PopupMenuItem(
                                value: 'folder:${f['id']}',
                                child: Text(f['name'] as String),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Eliminar'),
                            ),
                          ],
                          onSelected: (value) =>
                              _onMenuSelected(value, bookmark),
                        ),
                        onTap: () => context.push(
                          '/read/${bookmark.versionId}/${bookmark.bookId}/${bookmark.chapter}',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _onMenuSelected(String value, domain.Bookmark bookmark) async {
    final db = ref.read(appDatabaseProvider);
    if (value == 'delete') {
      await db.customUpdate(
        'DELETE FROM bookmarks WHERE id = ?',
        variables: [Variable.withInt(bookmark.id)],
      );
      ref.invalidate(bookmarksProvider);
      return;
    }
    if (value == 'uncategorized') {
      await db.setBookmarkFolder(bookmark.id, null);
    } else if (value.startsWith('folder:')) {
      final id = int.parse(value.split(':')[1]);
      await db.setBookmarkFolder(bookmark.id, id);
    }
    ref.invalidate(bookmarksProvider);
  }

  Future<void> _createFolder(BuildContext context) async {
    final controller = TextEditingController();
    final colors = [
      '#F2C94C',
      '#27AE60',
      '#2D9CDB',
      '#EB5757',
      '#9B51E0',
      '#F2994A',
    ];
    String color = colors.first;
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nueva carpeta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Nombre de la carpeta',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: colors
                    .map(
                      (c) => GestureDetector(
                        onTap: () => setState(() => color = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(c.replaceFirst('#', '0xFF')),
                            ),
                            shape: BoxShape.circle,
                            border: color == c
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      await BookmarkFolderActions(ref).create(result, color);
    }
  }

  void _confirmDeleteFolder(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar carpeta'),
        content: const Text(
          'Los marcadores en esta carpeta pasaran a "Sin carpeta".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              BookmarkFolderActions(ref).delete(id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _FolderChip extends StatelessWidget {
  final String label;
  final String? color;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _FolderChip({
    required this.label,
    this.color,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color != null
        ? Color(int.parse(color!.replaceFirst('#', '0xFF')))
        : theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Chip(
          avatar: color != null
              ? CircleAvatar(backgroundColor: chipColor, radius: 6)
              : null,
          label: Text(label),
          backgroundColor: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          labelStyle: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
