# 01 — Setup y Prerequisitos

## Requisitos

| Herramienta | Versión | Propósito |
|---|---|---|
| Flutter | stable (3.x) | Framework UI |
| Dart | incluido con Flutter | Lenguaje |
| Android Studio / Xcode | según plataforma | Build nativo |
| Git | latest | Control de versiones |

## Instalación

```powershell
# Verificar Flutter
flutter doctor

# Clonar
git clone <repo-url>
cd 51biblia

# Obtener dependencias
flutter pub get

# Generar código de drift (build_runner)
dart run build_runner build --delete-conflicting-outputs
```

## Ejecutar en desarrollo

```powershell
# Android (emulador o dispositivo físico)
flutter run

# Chrome
flutter run -d chrome

# iOS (requiere macOS + Xcode)
flutter run -d ios
```

## Build para distribución

```powershell
# Android APK (split por ABI)
flutter build apk --split-per-abi

# Android App Bundle (Play Store)
flutter build appbundle

# iOS (sin code signing para test)
flutter build ios --no-codesign
```

## Estructura del proyecto

```
51biblia/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── app.dart                     # Widget raíz con providers + router
│   ├── core/
│   │   ├── database/
│   │   │   ├── app_database.dart    # Instancia de la DB (drift)
│   │   │   ├── tables.dart          # Tablas SQLite
│   │   │   └── daos/                # Data Access Objects
│   │   ├── theme/
│   │   │   ├── app_theme.dart       # Temas claro/oscuro/sepia
│   │   │   └── font_manager.dart    # Gestión de fuentes y tamaños
│   │   ├── router/
│   │   │   └── app_router.dart      # go_router config
│   │   ├── utils/
│   │   │   ├── verse_reference.dart  # Parseo de referencias bíblicas
│   │   │   └── verse_image_generator.dart  # Generar imagen para compartir
│   │   └── constants/
│   │       └── bible_metadata.dart   # Nombres de libros, abreviaturas
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── bible_local_datasource.dart
│   │   │   │   ├── bookmark_datasource.dart
│   │   │   │   ├── highlight_datasource.dart
│   │   │   │   └── note_datasource.dart
│   │   │   └── remote/
│   │   │       └── bible_remote_datasource.dart  # Descargar versiones
│   │   ├── repositories/
│   │   │   ├── bible_repository_impl.dart
│   │   │   ├── search_repository_impl.dart
│   │   │   ├── bookmark_repository_impl.dart
│   │   │   ├── highlight_repository_impl.dart
│   │   │   ├── note_repository_impl.dart
│   │   │   └── reading_plan_repository_impl.dart
│   │   └── models/
│   │       └── ... (modelos con fromJson/toJson)
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── verse.dart
│   │   │   ├── book.dart
│   │   │   ├── bookmark.dart
│   │   │   ├── highlight.dart
│   │   │   ├── note.dart
│   │   │   ├── reading_plan.dart
│   │   │   └── reading_progress.dart
│   │   ├── repositories/
│   │   │   ├── bible_repository.dart      # Interfaz abstracta
│   │   │   ├── search_repository.dart
│   │   │   ├── bookmark_repository.dart
│   │   │   ├── highlight_repository.dart
│   │   │   ├── note_repository.dart
│   │   │   └── reading_plan_repository.dart
│   │   └── usecases/
│   │       └── ... (casos de uso)
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── bible_providers.dart
│   │   │   ├── search_provider.dart
│   │   │   ├── bookmark_providers.dart
│   │   │   ├── highlight_providers.dart
│   │   │   ├── note_providers.dart
│   │   │   ├── reading_plan_providers.dart
│   │   │   └── settings_providers.dart
│   │   ├── screens/
│   │   │   ├── home/
│   │   │   ├── bible_reader/
│   │   │   ├── book_selector/
│   │   │   ├── chapter_selector/
│   │   │   ├── search/
│   │   │   ├── bookmarks/
│   │   │   ├── notes/
│   │   │   ├── highlights/
│   │   │   ├── reading_plan/
│   │   │   └── settings/
│   │   └── shared/
│   │       ├── verse_tile.dart
│   │       ├── verse_actions_sheet.dart
│   │       └── bible_version_picker.dart
│   └── l10n/
│       ├── app_es.arb
│       └── app_en.arb
├── assets/
│   └── bibles/              # Bases de datos pre-pobladas
├── docs/                    # Documentación
├── test/                    # Tests
├── android/
├── ios/
└── pubspec.yaml
```
