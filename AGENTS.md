# AGENTS.md — Biblia

## Stack
- **Framework**: Flutter (stable channel)
- **Lenguaje**: Dart
- **Estado**: Riverpod (flutter_riverpod)
- **DB**: drift (SQLite + FTS5)
- **Routing**: go_router
- **Target**: Android + iOS

## Arquitectura: Clean Architecture (SOLID + DRY + KISS)

```
lib/
├── core/               # DB, theme, router, utils, constantes
├── data/               # Datasources, repos concretos, modelos
├── domain/             # Entidades, interfaces, casos de uso
├── presentation/       # Providers, screens, shared widgets
└── l10n/               # Traducciones ARB
```

## Principios
- **SOLID**: interfaces abstractas en domain/, inyección con Riverpod
- **DRY**: widgets compartidos, utilities, theme unificado
- **KISS**: navegación plana, sin overengineering

## Reglas al escribir código
1. **Nunca hardcodear secrets**. Todo en .env + variables de entorno.
2. **DRY**: si ves código repetido, extraelo a función/widget.
3. **Singleton** para DB pool, clientes HTTP.
4. **Functions cortas** (< 40 líneas), early returns, guard clauses.
5. **Nombres claros**: `GetChapterVerses` > `Get`.
6. **Comentarios**: solo cuando explican el POR QUÉ, no el qué.
7. **Conventional Commits**: `feat(scope): msg`, `fix(scope): msg`, etc.
8. Antes de commit: `dart format .` + `flutter analyze`

## Comandos comunes
```powershell
# Desarrollo
flutter run
flutter run -d chrome
dart format .
flutter analyze

# Build
flutter build apk --split-per-abi
flutter build ios --no-codesign
flutter build appbundle

# DB
dart run build_runner build --delete-conflicting-outputs
```

## Dependencias principales
| Paquete | Versión | Propósito |
|---|---|---|
| flutter_riverpod | latest | Estado + DI |
| drift | latest | SQLite + FTS5 |
| go_router | latest | Routing |
| sqlite3_flutter_libs | latest | SQLite nativo |
| path_provider | latest | Paths de archivos |
| share_plus | latest | Compartir |
| flutter_local_notifications | latest | Recordatorios |
| flutter_localizations + intl | latest | i18n |
| google_fonts | latest | Tipografía |
| flex_color_scheme | latest | Tema Material 3 |
| flutter_launcher_icons | latest | App icon |
| flutter_native_splash | latest | Splash |
| screenshot | latest | Captura widget a imagen |
| path_provider | latest | Directorios |
| package_info_plus | latest | Info de app |
