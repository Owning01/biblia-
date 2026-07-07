import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/database/app_database.dart';
import '../../providers/settings_providers.dart';
import '../../providers/user_data_providers.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final requestsAsync = ref.watch(prayerRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad'),
        actions: [
          if (userName.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Cambiar nombre',
              onPressed: () => _showNameDialog(context, ref, userName),
            ),
        ],
      ),
      body: Column(
        children: [
          _NameBanner(userName: userName, ref: ref),
          if (userName.isNotEmpty) ...[
            _NewRequestCard(ref: ref, userName: userName),
            const SizedBox(height: 8),
            Expanded(
              child: requestsAsync.when(
                data: (requests) {
                  if (requests.isEmpty) {
                    return Center(
                      child: Text(
                        'Se el primero en pedir oracion',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final r = requests[index];
                      return _PrayerCard(
                        request: r,
                        userName: userName,
                        ref: ref,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showNameDialog(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tu nombre'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu nombre',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(userNameProvider.notifier).setName(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _NameBanner extends ConsumerWidget {
  final String userName;
  final WidgetRef ref;

  const _NameBanner({required this.userName, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (userName.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.people_rounded,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'Bienvenido a la comunidad',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Asignate un nombre para poder participar',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  final ctx = context;
                  showDialog(
                    context: ctx,
                    builder: (ctx2) {
                      final ctrl = TextEditingController();
                      return AlertDialog(
                        title: const Text('Tu nombre'),
                        content: TextField(
                          controller: ctrl,
                          decoration: const InputDecoration(
                            hintText: 'Ingresa tu nombre',
                            border: OutlineInputBorder(),
                          ),
                          autofocus: true,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx2),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () {
                              ref
                                  .read(userNameProvider.notifier)
                                  .setName(ctrl.text);
                              Navigator.pop(ctx2);
                            },
                            child: const Text('Guardar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.person_add_outlined, size: 20),
                label: const Text('Asignar nombre'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Hola, $userName',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewRequestCard extends ConsumerWidget {
  final WidgetRef ref;
  final String userName;

  const _NewRequestCard({required this.ref, required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showNewRequest(context, ref, userName),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Comparte tu peticion de oracion...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNewRequest(BuildContext context, WidgetRef ref, String userName) {
    final controller = TextEditingController();
    final isAnon = ValueNotifier(false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    ctx,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nueva peticion',
              style: Theme.of(
                ctx,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Escribe tu peticion de oracion...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: isAnon,
              builder: (context, v, _) {
                return Row(
                  children: [
                    Switch(value: v, onChanged: (val) => isAnon.value = val),
                    const SizedBox(width: 8),
                    Text(
                      'Publicar como anonimo',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  final db = ref.read(appDatabaseProvider);
                  await db.customInsert(
                    'INSERT INTO prayer_requests (author_name, content, is_anonymous, created_at) VALUES (?, ?, ?, ?)',
                    variables: [
                      Variable.withString(userName),
                      Variable.withString(controller.text.trim()),
                      Variable.withInt(isAnon.value ? 1 : 0),
                      Variable.withString(DateTime.now().toIso8601String()),
                    ],
                  );
                  ref.invalidate(prayerRequestsProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Publicar'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PrayerCard extends ConsumerWidget {
  final Map<String, dynamic> request;
  final String userName;
  final WidgetRef ref;

  const _PrayerCard({
    required this.request,
    required this.userName,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final id = request['id'] as int;
    final authorName = request['author_name'] as String;
    final content = request['content'] as String;
    final isAnonymous = request['is_anonymous'] as int == 1;
    final prayerCount = request['prayer_count'] as int;
    final createdAt = DateTime.parse(request['created_at'] as String);
    final hasPrayedAsync = ref.watch(
      hasPrayedProvider((requestId: id, userName: userName)),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    isAnonymous
                        ? '🙏'
                        : (authorName.isNotEmpty
                              ? authorName[0].toUpperCase()
                              : '?'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isAnonymous ? null : theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isAnonymous ? 'Anonimo' : authorName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  timeago.format(createdAt, locale: 'es'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                hasPrayedAsync.when(
                  data: (hasPrayed) {
                    return _ActionButton(
                      icon: hasPrayed ? Icons.favorite : Icons.favorite_border,
                      label: 'Orar',
                      count: prayerCount,
                      active: hasPrayed,
                      onTap: () async {
                        if (hasPrayed) return;
                        final db = ref.read(appDatabaseProvider);
                        await db.customInsert(
                          'INSERT INTO prayer_actions (request_id, user_name, created_at) VALUES (?, ?, ?)',
                          variables: [
                            Variable.withInt(id),
                            Variable.withString(userName),
                            Variable.withString(
                              DateTime.now().toIso8601String(),
                            ),
                          ],
                        );
                        await db.customInsert(
                          'UPDATE prayer_requests SET prayer_count = prayer_count + 1 WHERE id = ?',
                          variables: [Variable.withInt(id)],
                        );
                        ref.invalidate(prayerRequestsProvider);
                        ref.invalidate(hasPrayedProvider);
                      },
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
