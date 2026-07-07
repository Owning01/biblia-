import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/bible_metadata.dart';
import '../../../core/utils/verse_reference.dart';
import '../../../domain/entities/verse.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ej: "Juan 3:16", "amor", "en el principio"...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchState.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchProvider.notifier).clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                ref.read(searchProvider.notifier).search(value);
              },
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(child: _buildResults(searchState, theme)),
        ],
      ),
    );
  }

  Widget _buildResults(SearchState state, ThemeData theme) {
    if (state.query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Busca versiculos, libros o referencias',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.reference != null) {
      return _ReferenceResult(
        parsedRef: state.reference!,
        results: state.results,
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Error al buscar', style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }

    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return _GroupedResults(results: state.results);
  }
}

class _ReferenceResult extends ConsumerWidget {
  final ParsedReference parsedRef;
  final List<Verse> results;
  const _ReferenceResult({required this.parsedRef, required this.results});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionId = ref.watch(activeVersionProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            leading: const Icon(Icons.book),
            title: Text('${parsedRef.bookName} ${parsedRef.chapter ?? ''}'),
            subtitle: const Text('Toca para ir al capitulo'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.push(
              '/read/$versionId/${parsedRef.bookId}/${parsedRef.chapter ?? 1}',
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...results.map(
          (verse) => ListTile(
            dense: true,
            title: Text(
              '${parsedRef.bookName} ${verse.chapter}:${verse.verse}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              verse.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => context.push(
              '/read/$versionId/${verse.bookId}/${verse.chapter}',
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupedResults extends StatelessWidget {
  final List<Verse> results;
  const _GroupedResults({required this.results});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Verse>>{};
    for (final verse in results) {
      final book = booksById[verse.bookId];
      final key = book?.name ?? 'Desconocido';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(verse);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...entry.value.map(
              (verse) => ListTile(
                dense: true,
                title: Text(
                  '${verse.chapter}:${verse.verse}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  verse.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => context.push(
                  '/read/${verse.versionId}/${verse.bookId}/${verse.chapter}',
                ),
              ),
            ),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }
}
