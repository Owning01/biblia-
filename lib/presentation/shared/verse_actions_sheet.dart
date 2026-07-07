import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/bible_metadata.dart';
import '../../domain/entities/verse.dart';

class VerseActionsSheet extends StatelessWidget {
  final Verse verse;
  final bool isBookmarked;
  final String? highlightColor;
  final void Function()? onBookmark;
  final void Function(String color)? onHighlight;
  final void Function()? onNote;
  final void Function()? onShare;
  final void Function()? onShareImage;

  const VerseActionsSheet({
    super.key,
    required this.verse,
    this.isBookmarked = false,
    this.highlightColor,
    this.onBookmark,
    this.onHighlight,
    this.onNote,
    this.onShare,
    this.onShareImage,
  });

  static const highlightColors = [
    '#FFFF00',
    '#4CAF50',
    '#2196F3',
    '#E91E63',
    '#FF9800',
    '#9C27B0',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = booksById[verse.bookId];
    final ref = '${book?.name ?? ''} ${verse.chapter}:${verse.verse}';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '"${verse.text}"',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ref,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ActionButton(
                      icon: isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      label: isBookmarked ? 'Quitar' : 'Marcador',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onBookmark?.call();
                      },
                    ),
                    _ActionButton(
                      icon: Icons.palette_outlined,
                      label: 'Subrayar',
                      onTap: () => _showColorPicker(context),
                    ),
                    _ActionButton(
                      icon: Icons.note_add_outlined,
                      label: 'Nota',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onNote?.call();
                      },
                    ),
                    _ActionButton(
                      icon: Icons.share_outlined,
                      label: 'Compartir',
                      onTap: () => _showShareOptions(context),
                    ),
                  ],
                ),
                if (highlightColor != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => onHighlight?.call(''),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Quitar subrayado'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Elegir color', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: highlightColors.map((color) {
                      final isActive = color == highlightColor;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(ctx);
                          onHighlight?.call(color);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          width: isActive ? 48 : 44,
                          height: isActive ? 48 : 44,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(color.replaceFirst('#', '0xFF')),
                            ),
                            shape: BoxShape.circle,
                            border: isActive
                                ? Border.all(color: Colors.white, width: 3)
                                : Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: Color(
                                        int.parse(
                                          color.replaceFirst('#', '0xFF'),
                                        ),
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isActive
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    final theme = Theme.of(context);
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Compartir', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: const Text('Como texto'),
                    onTap: () {
                      Navigator.pop(ctx);
                      onShare?.call();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.image_outlined),
                    title: const Text('Como imagen'),
                    onTap: () {
                      Navigator.pop(ctx);
                      onShareImage?.call();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
