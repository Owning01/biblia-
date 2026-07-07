import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/book_selector/book_selector_screen.dart';
import '../../presentation/screens/bible_reader/bible_reader_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/bookmarks/bookmarks_screen.dart';
import '../../presentation/screens/notes/notes_screen.dart';
import '../../presentation/screens/highlights/highlights_screen.dart';
import '../../presentation/screens/reading_plan/reading_plan_screen.dart';
import '../../presentation/screens/community/community_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/bookmarks',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const BookmarksScreen(),
            ),
          ),
          GoRoute(
            path: '/reading-plan',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ReadingPlanScreen(),
            ),
          ),
          GoRoute(
            path: '/community',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CommunityScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/books',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BookSelectorScreen(),
      ),
      GoRoute(
        path: '/books/:bookId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BookSelectorScreen(
          initialBookId: int.tryParse(state.pathParameters['bookId'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/read/:versionId/:bookId/:chapter',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BibleReaderScreen(
          versionId: state.pathParameters['versionId'] ?? 'rv1960',
          bookId: int.parse(state.pathParameters['bookId'] ?? '1'),
          chapter: int.parse(state.pathParameters['chapter'] ?? '1'),
        ),
      ),
      GoRoute(
        path: '/notes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/highlights',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HighlightsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Leer',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Comunidad',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/bookmarks')) return 2;
    if (location.startsWith('/reading-plan')) return 3;
    if (location.startsWith('/community')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/search');
      case 2:
        context.go('/bookmarks');
      case 3:
        context.go('/reading-plan');
      case 4:
        context.go('/community');
    }
  }
}
