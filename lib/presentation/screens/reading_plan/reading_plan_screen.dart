import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/database/app_database.dart';
import '../../providers/user_data_providers.dart';

class ReadingPlanScreen extends ConsumerWidget {
  const ReadingPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(readingPlansProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Plan de Lectura')),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay planes disponibles',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final planId = plan['id'] as int;
              final name = plan['name'] as String;
              final description = plan['description'] as String?;
              final durationDays = plan['duration_days'] as int;
              final descriptionText = description ?? '';

              return _PlanCard(
                planId: planId,
                name: name,
                description: descriptionText,
                durationDays: durationDays,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final int planId;
  final String name;
  final String description;
  final int durationDays;

  const _PlanCard({
    required this.planId,
    required this.name,
    required this.description,
    required this.durationDays,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(readingProgressProvider(planId));
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(description, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            progressAsync.when(
              data: (completedDays) {
                final progress = completedDays.length;
                final percent = durationDays > 0
                    ? progress / durationDays
                    : 0.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$progress / $durationDays dias (${(percent * 100).toStringAsFixed(0)}%)',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    _DayGrid(
                      planId: planId,
                      durationDays: durationDays,
                      completedDays: completedDays,
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error al cargar progreso'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayGrid extends ConsumerWidget {
  final int planId;
  final int durationDays;
  final Set<int> completedDays;

  const _DayGrid({
    required this.planId,
    required this.durationDays,
    required this.completedDays,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysToShow = durationDays > 100 ? 100 : durationDays;
    return SizedBox(
      height: 120,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: daysToShow,
        itemBuilder: (context, index) {
          final day = index + 1;
          final isCompleted = completedDays.contains(day);
          return GestureDetector(
            onTap: () async {
              final db = ref.read(appDatabaseProvider);
              if (!isCompleted) {
                await db.customInsert(
                  'INSERT INTO reading_progress (plan_id, day, completed, completed_at) VALUES (?, ?, 1, ?)',
                  variables: [
                    Variable.withInt(planId),
                    Variable.withInt(day),
                    Variable.withString(DateTime.now().toIso8601String()),
                  ],
                );
                ref.invalidate(readingProgressProvider);
              }

              final dayData = await db
                  .customSelect(
                    'SELECT * FROM reading_plan_days WHERE plan_id = ? AND day = ?',
                    variables: [
                      Variable.withInt(planId),
                      Variable.withInt(day),
                    ],
                  )
                  .get();

              if (dayData.isNotEmpty && context.mounted) {
                final row = dayData.first.data;
                final versionId = row['version_id'] as String;
                final bookId = row['book_id'] as int;
                final chapter = row['chapter'] as int;
                context.push('/read/$versionId/$bookId/$chapter');
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 10,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
