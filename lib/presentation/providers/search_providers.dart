import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart' hide Verse;
import '../../core/utils/verse_reference.dart';
import '../../domain/entities/verse.dart';

class SearchState {
  final String query;
  final bool isSearching;
  final List<Verse> results;
  final ParsedReference? reference;
  final String? error;

  const SearchState({
    this.query = '',
    this.isSearching = false,
    this.results = const [],
    this.reference,
    this.error,
  });

  SearchState copyWith({
    String? query,
    bool? isSearching,
    List<Verse>? results,
    ParsedReference? reference,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      results: results ?? this.results,
      reference: reference ?? this.reference,
      error: error,
    );
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier(ref);
});

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;

  SearchNotifier(this._ref) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isSearching: true, error: null);

    final parsed = VerseReference.parse(query);
    final db = _ref.read(appDatabaseProvider);

    if (parsed.isReference && parsed.reference != null) {
      state = state.copyWith(reference: parsed.reference);
    }

    try {
      final rows = await db.searchFts(query);
      state = state.copyWith(
        results: rows.map(Verse.fromMap).toList(),
        isSearching: false,
      );
    } catch (_) {
      try {
        final rows = await db.searchByText(query);
        state = state.copyWith(
          results: rows.map(Verse.fromMap).toList(),
          isSearching: false,
        );
      } catch (e) {
        state = state.copyWith(
          results: [],
          isSearching: false,
          error: e.toString(),
        );
      }
    }
  }

  void clear() {
    state = const SearchState();
  }
}
