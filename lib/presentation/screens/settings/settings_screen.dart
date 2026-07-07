import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final colorSchemeIndex = ref.watch(colorSchemeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final fontFamily = ref.watch(fontFamilyProvider);
    final activeVersion = ref.watch(activeVersionProvider);
    final margin = ref.watch(readingMarginProvider);
    final verseSpacing = ref.watch(verseSpacingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _SectionTitle(title: 'Apariencia'),
          const SizedBox(height: 12),
          _PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingRow(
                  icon: Icons.palette_outlined,
                  title: 'Tema',
                  trailing: SegmentedButton<AppThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.light,
                        icon: Icon(Icons.light_mode, size: 18),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        icon: Icon(Icons.dark_mode, size: 18),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.sepia,
                        icon: Icon(Icons.bedtime_outlined, size: 18),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (value) {
                      HapticFeedback.selectionClick();
                      ref
                          .read(appThemeModeProvider.notifier)
                          .setMode(value.first);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Esquema de colores',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: _ColorPicker(
                    selectedIndex: colorSchemeIndex,
                    onChanged: (i) {
                      HapticFeedback.selectionClick();
                      ref.read(colorSchemeProvider.notifier).setScheme(i);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                _SettingRow(
                  icon: Icons.font_download_outlined,
                  title: 'Fuente',
                  subtitle: FontOption.options
                      .firstWhere((f) => f.fontFamily == fontFamily)
                      .name,
                  trailing: _StyledDropdown<String>(
                    value: fontFamily,
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
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tamano de letra',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${fontSize.round()} sp',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      Slider(
                        value: fontSize,
                        min: 12,
                        max: 28,
                        divisions: 16,
                        label: '${fontSize.round()} sp',
                        onChanged: (value) {
                          ref.read(fontSizeProvider.notifier).setSize(value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Lectura'),
          const SizedBox(height: 12),
          _PremiumCard(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Margen',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${margin.toInt()} px',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
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
                          ref
                              .read(readingMarginProvider.notifier)
                              .setMargin(value);
                        },
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Espacio entre versiculos',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${verseSpacing.toInt()} px',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
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
                          ref
                              .read(verseSpacingProvider.notifier)
                              .setSpacing(value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Biblia'),
          const SizedBox(height: 12),
          _PremiumCard(
            child: _SettingRow(
              icon: Icons.translate,
              title: 'Version activa',
              subtitle: _versionName(activeVersion),
              trailing: _StyledDropdown<String>(
                value: activeVersion,
                items: const [
                  DropdownMenuItem(
                    value: 'rv1960',
                    child: Text('Reina Valera 1960'),
                  ),
                  DropdownMenuItem(
                    value: 'rv1995',
                    child: Text('Reina Valera 1995'),
                  ),
                  DropdownMenuItem(value: 'nvi', child: Text('NVI')),
                  DropdownMenuItem(value: 'pdt', child: Text('PDT')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    HapticFeedback.selectionClick();
                    ref.read(activeVersionProvider.notifier).setVersion(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Acerca de'),
          const SizedBox(height: 12),
          _PremiumCard(
            child: Column(
              children: [
                _SettingRow(
                  icon: Icons.info_outline,
                  title: 'Biblia',
                  subtitle: 'Version 1.0.0',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                _SettingRow(
                  icon: Icons.description_outlined,
                  title: 'Terminos y privacidad',
                  showArrow: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _versionName(String versionId) {
    switch (versionId) {
      case 'rv1960':
        return 'Reina Valera 1960';
      case 'rv1995':
        return 'Reina Valera 1995';
      case 'nvi':
        return 'NVI';
      case 'pdt':
        return 'PDT';
      default:
        return versionId;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary.withValues(alpha: 0.8),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface.withValues(alpha: 0.6)
            : theme.colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showArrow;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailingWidget = trailing;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingWidget != null) trailingWidget,
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ColorPicker extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _ColorPicker({required this.selectedIndex, required this.onChanged});

  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker>
    with SingleTickerProviderStateMixin {
  int? _animatingIndex;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(ColorSchemeOption.options.length, (i) {
        final opt = ColorSchemeOption.options[i];
        final isSelected = i == widget.selectedIndex;
        final isAnimating = i == _animatingIndex;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _animatingIndex = i);
            widget.onChanged(i);
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _animatingIndex = null);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: isAnimating ? 48 : 40,
            height: isAnimating ? 48 : 40,
            decoration: BoxDecoration(
              color: opt.color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 2.5,
                    )
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: opt.color.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 18,
                  )
                : null,
          ),
        );
      }),
    );
  }
}
