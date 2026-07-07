import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

enum AppThemeMode { light, dark, sepia }

const Color sepiaBg = Color(0xFFF5E6C8);
const Color sepiaText = Color(0xFF5C3A1E);
const Color sepiaPrimary = Color(0xFF8B5E3C);

class ColorSchemeOption {
  final String name;
  final FlexScheme scheme;
  final Color color;

  const ColorSchemeOption(this.name, this.scheme, this.color);

  static final List<ColorSchemeOption> options = [
    const ColorSchemeOption('Azul', FlexScheme.brandBlue, Color(0xFF2196F3)),
    const ColorSchemeOption('Verde', FlexScheme.green, Color(0xFF4CAF50)),
    const ColorSchemeOption(
      'Purpura',
      FlexScheme.purpleBrown,
      Color(0xFF9C27B0),
    ),
    const ColorSchemeOption('Rojo', FlexScheme.red, Color(0xFFE53935)),
    const ColorSchemeOption('Rosa', FlexScheme.sakura, Color(0xFFE91E63)),
    const ColorSchemeOption('Ambar', FlexScheme.amber, Color(0xFFFFC107)),
    const ColorSchemeOption('Teal', FlexScheme.tealM3, Color(0xFF009688)),
    const ColorSchemeOption('Dorado', FlexScheme.gold, Color(0xFFFFD700)),
    const ColorSchemeOption('Mango', FlexScheme.mango, Color(0xFFFF9800)),
    const ColorSchemeOption('Indigo', FlexScheme.indigo, Color(0xFF3F51B5)),
    const ColorSchemeOption('Jungla', FlexScheme.jungle, Color(0xFF2E7D32)),
    const ColorSchemeOption('Gris', FlexScheme.greyLaw, Color(0xFF607D8B)),
    const ColorSchemeOption('Sepia', FlexScheme.sepia, Color(0xFF8B6F47)),
    const ColorSchemeOption(
      'Deep Blue',
      FlexScheme.deepBlue,
      Color(0xFF0D47A1),
    ),
  ];
}

const Color darkNavyBg = Color(0xFF121824);
const Color darkNavySurface = Color(0xFF1A2235);
const Color darkNavyCard = Color(0xFF1E293B);

class AppTheme {
  static ThemeData _base({
    required bool isDark,
    FlexScheme scheme = FlexScheme.brandBlue,
  }) {
    final builder = isDark ? FlexThemeData.dark : FlexThemeData.light;
    return builder(
      scheme: scheme,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: isDark ? 15 : 13,
      appBarStyle: FlexAppBarStyle.background,
    );
  }

  static ThemeData light({FlexScheme scheme = FlexScheme.brandBlue}) =>
      _base(isDark: false, scheme: scheme);

  static ThemeData dark({FlexScheme scheme = FlexScheme.brandBlue}) {
    final base = _base(isDark: true, scheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: darkNavyBg,
      colorScheme: base.colorScheme.copyWith(
        surface: darkNavySurface,
        surfaceContainerLowest: darkNavyBg,
        surfaceContainerLow: darkNavySurface,
        surfaceContainer: darkNavyCard,
        surfaceContainerHigh: const Color(0xFF253248),
        surfaceContainerHighest: const Color(0xFF2D3A52),
        onSurface: const Color(0xFFE2E8F0),
        onSurfaceVariant: const Color(0xFF94A3B8),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: darkNavyBg,
        foregroundColor: const Color(0xFFE2E8F0),
      ),
      cardTheme: base.cardTheme.copyWith(color: darkNavyCard),
      dialogTheme: base.dialogTheme.copyWith(backgroundColor: darkNavyCard),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: darkNavyCard,
      ),
    );
  }

  static ThemeData sepia({FlexScheme scheme = FlexScheme.brandBlue}) {
    final base = _base(isDark: false, scheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: sepiaBg,
      colorScheme: base.colorScheme.copyWith(
        surface: sepiaBg,
        onSurface: sepiaText,
        primary: sepiaPrimary,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: sepiaBg,
        foregroundColor: sepiaText,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: Colors.white.withValues(alpha: 0.6),
      ),
    );
  }

  static ThemeData fromMode(
    AppThemeMode mode, {
    FlexScheme scheme = FlexScheme.brandBlue,
  }) {
    switch (mode) {
      case AppThemeMode.light:
        return light(scheme: scheme);
      case AppThemeMode.dark:
        return dark(scheme: scheme);
      case AppThemeMode.sepia:
        return sepia(scheme: scheme);
    }
  }
}

class FontOption {
  final String name;
  final String fontFamily;

  const FontOption(this.name, this.fontFamily);

  static const List<FontOption> options = [
    FontOption('Inter', 'Inter'),
    FontOption('Roboto', 'Roboto'),
    FontOption('Noto Serif', 'Noto Serif'),
    FontOption('Lora', 'Lora'),
    FontOption('Merriweather', 'Merriweather'),
    FontOption('Playfair Display', 'Playfair Display'),
    FontOption('JetBrains Mono', 'JetBrains Mono'),
    FontOption('Crimson Text', 'Crimson Text'),
    FontOption('Atkinson Hyperlegible', 'Atkinson Hyperlegible'),
    FontOption('Source Serif 4', 'Source Serif 4'),
  ];
}
