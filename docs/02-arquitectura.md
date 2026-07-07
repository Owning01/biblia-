# 02 — Arquitectura

## Diagrama de capas

```
┌──────────────────────────────────────────────────────┐
│                    PRESENTATION                       │
│  Screens (Riverpod) → Shared Widgets                  │
│  Providers → State notifica cambios a screens         │
└──────────────────┬───────────────────────────────────┘
                   │ depende de interfaces abstractas
                   ▼
┌──────────────────────────────────────────────────────┐
│                      DOMAIN                           │
│  Entities (objetos puros)                             │
│  Repository interfaces (abstractas)                   │
│  Use Cases (lógica de negocio pura)                   │
└──────────────────┬───────────────────────────────────┘
                   │ implementa interfaces
                   ▼
┌──────────────────────────────────────────────────────┐
│                       DATA                            │
│  Datasources (local SQLite / remote HTTP)             │
│  Repository implementations (orquestan datasources)   │
│  Models (fromJson/toJson, maps DB ↔ Domain)           │
└──────────────────┬───────────────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────────────┐
│                       CORE                            │
│  Database (drift + FTS5)                              │
│  Theme (claro/oscuro/sepia + fuentes)                 │
│  Router (go_router)                                   │
│  Utils (referencias, imágenes)                        │
└──────────────────────────────────────────────────────┘
```

## Flujo de datos: Lectura de versículos

```
User tap Book "Juan"
       │
       ▼
BibleReaderScreen
       │
       ▼
bibleProvider(versionId, bookId, chapter)
       │ llama
       ▼
GetChapterVerses(useCase)
       │ llama
       ▼
BibleRepository.getChapterVerses(versionId, bookId, chapter)
       │ llama
       ▼
BibleLocalDatasource.getVerses(versionId, bookId, chapter)
       │ consulta SQLite + FTS5
       ▼
AppDatabase (drift → SQLite)
       │
       ▼
List<Verse> → Riverpod state → Screen rebuild
```

## Flujo de datos: Búsqueda

```
User escribe "Juan 3:16"
       │
       ▼
SearchScreen
       │ debounce 300ms
       ▼
searchProvider(query)
       │
       ├── ¿Es referencia? (parser detecta "Juan 3:16")
       │   → SearchRepository.searchByReference(query)
       │     → SQL: SELECT * FROM verses WHERE ref = "Juan 3:16"
       │
       └── ¿Es texto libre? ("amor paciencia")
           → SearchRepository.searchText(query)
             → FTS5: SELECT * FROM verses_fts WHERE text MATCH '"amor" "paciencia"'
```

## Flujo de datos: Compartir imagen

```
User tap "Compartir" en versículo
       │
       ▼
VerseActionsSheet → "Compartir como imagen"
       │
       ▼
VerseImageGenerator.generate(verse, theme, font)
       │ Renderiza widget en Offstage
       │ Captura con ScreenshotController → Uint8List PNG
       ▼
share_plus → Share.shareXFiles([imagen temporal])
       │
       ▼
Native share sheet del SO
```

## Diagrama de DB

```
bible_versions
┌─────────┬────────────┬──────────────┐
│ id (PK) │ name       │ abbreviation │
├─────────┼────────────┼──────────────┤
│ rv1960  │ Reina Valera 1960 │ RV60    │
│ nvi     │ Nueva Versión Int. │ NVI     │
└─────────┴────────────┴──────────────┘

books
┌──────┬──────────┬───────────────┬───────────┬──────────┐
│ id   │ name     │ abbreviation  │ testament │ position │
├──────┼──────────┼───────────────┼───────────┼──────────┤
│ 43   │ Juan     │ Jn           │ new       │ 4        │
└──────┴──────────┴───────────────┴───────────┴──────────┘

verses
┌──────────┬────────────┬─────────┬─────────┬───────┬──────┐
│ id (PK)  │ version_id │ book_id │ chapter │ verse │ text │
├──────────┼────────────┼─────────┼─────────┼───────┼──────┤
│ 261197   │ rv1960     │ 43      │ 3       │ 16    │ ...  │
└──────────┴────────────┴─────────┴─────────┴───────┴──────┘

verses_fts (FTS5 virtual table)
┌──────────┬─────────────────────┐
│ rowid    │ text                │
├──────────┼─────────────────────┤
│ 261197   │ ... (tokenized)     │
└──────────┴─────────────────────┘
```
