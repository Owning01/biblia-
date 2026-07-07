import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeNotifier, AppThemeMode>((ref) {
      return AppThemeModeNotifier(ref);
    });

class AppThemeModeNotifier extends StateNotifier<AppThemeMode> {
  final Ref _ref;

  AppThemeModeNotifier(this._ref) : super(AppThemeMode.light) {
    _load();
  }

  void _load() {
    final prefs = _ref.read(sharedPrefsProvider);
    final index = prefs.getInt('theme_mode') ?? 0;
    state = AppThemeMode.values[index];
  }

  void setMode(AppThemeMode mode) {
    state = mode;
    final prefs = _ref.read(sharedPrefsProvider);
    prefs.setInt('theme_mode', mode.index);
  }
}

final colorSchemeProvider = StateNotifierProvider<ColorSchemeNotifier, int>((
  ref,
) {
  return ColorSchemeNotifier(ref);
});

class ColorSchemeNotifier extends StateNotifier<int> {
  final Ref _ref;

  ColorSchemeNotifier(this._ref) : super(0) {
    _load();
  }

  void _load() {
    final prefs = _ref.read(sharedPrefsProvider);
    state = prefs.getInt('color_scheme') ?? 0;
  }

  void setScheme(int index) {
    state = index;
    final prefs = _ref.read(sharedPrefsProvider);
    prefs.setInt('color_scheme', index);
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier(ref);
});

class FontSizeNotifier extends StateNotifier<double> {
  final Ref _ref;

  FontSizeNotifier(this._ref) : super(18) {
    _load();
  }

  void _load() {
    final prefs = _ref.read(sharedPrefsProvider);
    state = prefs.getDouble('font_size') ?? 18;
  }

  void setSize(double size) {
    state = size;
    final prefs = _ref.read(sharedPrefsProvider);
    prefs.setDouble('font_size', size);
  }
}

final fontFamilyProvider = StateNotifierProvider<FontFamilyNotifier, String>((
  ref,
) {
  return FontFamilyNotifier(ref);
});

const _validFonts = {
  'Inter',
  'Roboto',
  'Noto Serif',
  'Lora',
  'Merriweather',
  'Playfair Display',
  'JetBrains Mono',
  'Crimson Text',
  'Atkinson Hyperlegible',
  'Source Serif 4',
};

class FontFamilyNotifier extends StateNotifier<String> {
  final Ref _ref;

  FontFamilyNotifier(this._ref) : super('Inter') {
    _load();
  }

  void _load() {
    final prefs = _ref.read(sharedPrefsProvider);
    final saved = prefs.getString('font_family') ?? 'Inter';
    state = _validFonts.contains(saved) ? saved : 'Inter';
    if (saved != state) prefs.setString('font_family', state);
  }

  void setFamily(String family) {
    state = family;
    final prefs = _ref.read(sharedPrefsProvider);
    prefs.setString('font_family', family);
  }
}

final activeVersionProvider =
    StateNotifierProvider<ActiveVersionNotifier, String>((ref) {
      return ActiveVersionNotifier(ref);
    });

class ActiveVersionNotifier extends StateNotifier<String> {
  final Ref _ref;

  ActiveVersionNotifier(this._ref) : super('rv1960') {
    _load();
  }

  void _load() {
    final prefs = _ref.read(sharedPrefsProvider);
    state = prefs.getString('active_version') ?? 'rv1960';
  }

  void setVersion(String versionId) {
    state = versionId;
    final prefs = _ref.read(sharedPrefsProvider);
    prefs.setString('active_version', versionId);
  }
}

final readingMarginProvider =
    StateNotifierProvider<ReadingMarginNotifier, double>((ref) {
      return ReadingMarginNotifier(ref);
    });

class ReadingMarginNotifier extends StateNotifier<double> {
  final Ref _ref;

  ReadingMarginNotifier(this._ref) : super(16) {
    _load();
  }

  void _load() {
    final prefs = _ref.read(sharedPrefsProvider);
    state = prefs.getDouble('reading_margin') ?? 16;
  }

  void setMargin(double margin) {
    state = margin;
    final prefs = _ref.read(sharedPrefsProvider);
    prefs.setDouble('reading_margin', margin);
  }
}

final verseSpacingProvider =
    StateNotifierProvider<VerseSpacingNotifier, double>((ref) {
      return VerseSpacingNotifier(ref);
    });

class VerseSpacingNotifier extends StateNotifier<double> {
  final Ref _ref;

  VerseSpacingNotifier(this._ref) : super(4) {
    _load();
  }

  void _load() {
    final prefs = _ref.read(sharedPrefsProvider);
    state = prefs.getDouble('verse_spacing') ?? 4;
  }

  void setSpacing(double spacing) {
    state = spacing;
    final prefs = _ref.read(sharedPrefsProvider);
    prefs.setDouble('verse_spacing', spacing);
  }
}

final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  return UserNameNotifier(ref);
});

class UserNameNotifier extends StateNotifier<String> {
  final Ref _ref;

  UserNameNotifier(this._ref) : super('') {
    _load();
  }

  void _load() {
    final prefs = _ref.read(sharedPrefsProvider);
    state = prefs.getString('user_name') ?? '';
  }

  void setName(String name) {
    state = name;
    final prefs = _ref.read(sharedPrefsProvider);
    prefs.setString('user_name', name);
  }
}
