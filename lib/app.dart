import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/settings_providers.dart';

class BibliaApp extends ConsumerStatefulWidget {
  const BibliaApp({super.key});

  @override
  ConsumerState<BibliaApp> createState() => _BibliaAppState();
}

class _BibliaAppState extends ConsumerState<BibliaApp> {
  bool _notificationsReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_notificationsReady) {
      _notificationsReady = true;
      _initNotifications();
    }
  }

  Future<void> _initNotifications() async {
    final notifications = ref.read(notificationServiceProvider);
    await notifications.init();
    final settings = ref.read(notificationSettingsProvider);
    if (settings.dailyVerseEnabled) {
      notifications.scheduleDailyVerse(settings.dailyVerseTime);
    }
    if (settings.reminderEnabled) {
      notifications.scheduleReadingReminder(settings.reminderTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeProvider);
    final colorSchemeIndex = ref.watch(colorSchemeProvider);
    final router = ref.watch(appRouterProvider);
    final fontFamily = ref.watch(fontFamilyProvider);

    final scheme = ColorSchemeOption.options[colorSchemeIndex].scheme;

    final lightTheme = AppTheme.fromMode(
      themeMode == AppThemeMode.sepia ? AppThemeMode.sepia : AppThemeMode.light,
      scheme: scheme,
    );
    final darkTheme = AppTheme.fromMode(AppThemeMode.dark, scheme: scheme);

    final textTheme = _buildTextTheme(fontFamily);
    final onSurfaceLight = lightTheme.colorScheme.onSurface;
    final onSurfaceDark = darkTheme.colorScheme.onSurface;

    return MaterialApp.router(
      title: 'Biblia',
      debugShowCheckedModeBanner: false,
      theme: lightTheme.copyWith(
        textTheme: textTheme.apply(
          bodyColor: onSurfaceLight,
          displayColor: onSurfaceLight,
        ),
      ),
      darkTheme: darkTheme.copyWith(
        textTheme: textTheme.apply(
          bodyColor: onSurfaceDark,
          displayColor: onSurfaceDark,
        ),
      ),
      themeMode: _resolveThemeMode(themeMode),
      routerConfig: router,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es'), Locale('en')],
      localeResolutionCallback: (locale, supported) {
        if (locale != null && supported.contains(locale)) return locale;
        return const Locale('es');
      },
    );
  }

  static const _validFonts = {
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

  TextTheme _buildTextTheme(String bodyFont) {
    final safeFont = _validFonts.contains(bodyFont) ? bodyFont : 'Inter';
    final bodyStyle = GoogleFonts.getFont(safeFont);
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      displaySmall: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      bodyLarge: bodyStyle.copyWith(height: 1.6),
      bodyMedium: bodyStyle.copyWith(height: 1.5),
      bodySmall: bodyStyle.copyWith(fontWeight: FontWeight.w400),
      labelLarge: bodyStyle,
      labelMedium: bodyStyle,
      labelSmall: bodyStyle,
    );
  }

  ThemeMode _resolveThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.sepia:
        return ThemeMode.light;
    }
  }
}
