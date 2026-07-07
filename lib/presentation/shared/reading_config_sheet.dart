import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/settings_providers.dart';

class ReadingConfigSheet extends ConsumerWidget {
  const ReadingConfigSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final fontFamily = ref.watch(fontFamilyProvider);
    final margin = ref.watch(readingMarginProvider);
    final verseSpacing = ref.watch(verseSpacingProvider);

    final theme = Theme.of(context);

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
          child: SingleChildScrollView(
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
                  'Configuracion de lectura',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Tema', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<AppThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemeMode.light,
                      label: Text('Claro'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      label: Text('Oscuro'),
                      icon: Icon(Icons.dark_mode),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.sepia,
                      label: Text('Sepia'),
                      icon: Icon(Icons.brightness_medium),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selected) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(appThemeModeProvider.notifier)
                        .setMode(selected.first);
                  },
                ),
                const SizedBox(height: 20),
                Text('Fuente', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: fontFamily,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: FontOption.options.map((f) {
                    return DropdownMenuItem(
                      value: f.fontFamily,
                      child: Text(f.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      HapticFeedback.selectionClick();
                      ref.read(fontFamilyProvider.notifier).setFamily(value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tamano', style: theme.textTheme.labelLarge),
                    Text(
                      '${fontSize.toInt()}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: fontSize,
                  min: 12,
                  max: 32,
                  divisions: 20,
                  label: '${fontSize.toInt()}',
                  onChanged: (value) {
                    ref.read(fontSizeProvider.notifier).setSize(value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Margen', style: theme.textTheme.labelLarge),
                    Text(
                      '${margin.toInt()}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: margin,
                  min: 8,
                  max: 48,
                  divisions: 20,
                  label: '${margin.toInt()}',
                  onChanged: (value) {
                    ref.read(readingMarginProvider.notifier).setMargin(value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Espacio entre versiculos',
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      '${verseSpacing.toInt()}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: verseSpacing,
                  min: 0,
                  max: 24,
                  divisions: 12,
                  label: '${verseSpacing.toInt()}',
                  onChanged: (value) {
                    ref.read(verseSpacingProvider.notifier).setSpacing(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
