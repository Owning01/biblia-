import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/bible_metadata.dart';
import '../../providers/bible_providers.dart';
import '../../providers/extra_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastRead = ref.watch(lastReadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          const _DailyVerseCard(),
          const SizedBox(height: 16),
          const _ReadingStatsCard(),
          if (lastRead != null) ...[
            const SizedBox(height: 28),
            _ContinueReadingCard(lastRead: lastRead),
          ],
          const SizedBox(height: 28),
          _SectionHeader(title: 'Antiguo Testamento'),
          const SizedBox(height: 12),
          _BookGrid(testament: 'old'),
          const SizedBox(height: 28),
          _SectionHeader(title: 'Nuevo Testamento'),
          const SizedBox(height: 12),
          _BookGrid(testament: 'new'),
        ],
      ),
    );
  }
}

class _DailyVerseCard extends ConsumerWidget {
  const _DailyVerseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dailyAsync = ref.watch(dailyVerseProvider);

    return dailyAsync.when(
      data: (verse) {
        if (verse == null) return const SizedBox.shrink();
        final book = booksById[verse.bookId];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push(
                '/read/${verse.versionId}/${verse.bookId}/${verse.chapter}',
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.9,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'VERSÍCULO DEL DÍA',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.9,
                            ),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"${verse.text}"',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${book?.name ?? ''} ${verse.chapter}:${verse.verse}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.85,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ReadingStatsCard extends ConsumerWidget {
  const _ReadingStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final streakAsync = ref.watch(readingStreakProvider);
    final todayAsync = ref.watch(versesReadTodayProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: streakAsync.when(
                data: (streak) => _StatItem(
                  icon: Icons.local_fire_department_rounded,
                  value: '$streak',
                  label: 'días seguidos',
                ),
                loading: () => const _StatItem(
                  icon: Icons.local_fire_department_rounded,
                  value: '—',
                  label: 'días seguidos',
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
            Expanded(
              child: todayAsync.when(
                data: (today) => _StatItem(
                  icon: Icons.menu_book_rounded,
                  value: '$today',
                  label: 'versículos hoy',
                ),
                loading: () => const _StatItem(
                  icon: Icons.menu_book_rounded,
                  value: '—',
                  label: 'versículos hoy',
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.primary.withValues(alpha: 0.85),
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _ContinueReadingCard extends ConsumerWidget {
  final ({String versionId, int bookId, int chapter}) lastRead;
  const _ContinueReadingCard({required this.lastRead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final book = booksById[lastRead.bookId];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            theme.colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(
            '/read/${lastRead.versionId}/${lastRead.bookId}/${lastRead.chapter}',
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${book?.name ?? ''} ${lastRead.chapter}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toca para continuar leyendo',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookGrid extends ConsumerWidget {
  final String testament;
  const _BookGrid({required this.testament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    return booksAsync.when(
      data: (books) {
        final filtered = books
            .where((b) => b['testament'] as String == testament)
            .map((b) => (id: b['id'] as int, name: b['name'] as String))
            .toList();

        return Column(
          children: filtered.map((book) {
            final count = bookChapterCounts[book.id] ?? 1;
            return _BookListItem(
              name: book.name,
              chapterCount: count,
              onTap: () => context.push('/books/${book.id}'),
            );
          }).toList(),
        );
      },
      loading: () => _BookListShimmer(testament: testament),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _BookListItem extends StatelessWidget {
  final String name;
  final int chapterCount;
  final VoidCallback onTap;

  const _BookListItem({
    required this.name,
    required this.chapterCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$chapterCount cap.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookListShimmer extends StatelessWidget {
  final String testament;
  const _BookListShimmer({required this.testament});

  @override
  Widget build(BuildContext context) {
    final count = testament == 'old' ? 6 : 5;
    return Column(children: List.generate(count, (_) => _ShimmerRow()));
  }
}

class _ShimmerRow extends StatefulWidget {
  @override
  State<_ShimmerRow> createState() => _ShimmerRowState();
}

class _ShimmerRowState extends State<_ShimmerRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surfaceContainerHigh.withValues(
                        alpha: 0.4,
                      ),
                      theme.colorScheme.surfaceContainerHigh.withValues(
                        alpha: 0.2,
                      ),
                      theme.colorScheme.surfaceContainerHigh.withValues(
                        alpha: 0.4,
                      ),
                    ],
                    stops: [0.0, _animation.value.clamp(0.0, 1.0), 1.0],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.surfaceContainerHigh.withValues(
                          alpha: 0.4,
                        ),
                        theme.colorScheme.surfaceContainerHigh.withValues(
                          alpha: 0.2,
                        ),
                        theme.colorScheme.surfaceContainerHigh.withValues(
                          alpha: 0.4,
                        ),
                      ],
                      stops: [0.0, _animation.value.clamp(0.0, 1.0), 1.0],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 60),
            ],
          ),
        );
      },
    );
  }
}
