# 📖 Biblia App

Una aplicación de lectura y estudio de la Biblia desarrollada en **Flutter**, diseñada bajo los principios de **Clean Architecture** (SOLID + DRY + KISS) y enfocada en una experiencia de usuario premium, fluida y con alto rendimiento offline.

---

## ✨ Características Principales

* 🚀 **Alto Rendimiento Offline:** Motor de base de datos local ultra rápido utilizando **Drift (SQLite)** y búsqueda de texto completo con **FTS5**.
* 🎨 **Diseño Premium:** Interfaz refinada basada en **Material 3** usando **FlexColorScheme**, tipografía moderna (Outfit/Inter) y micro-animaciones fluidas.
* 🧠 **Arquitectura Limpia:** Separación estricta de responsabilidades en capas (`core/`, `data/`, `domain/`, `presentation/`).
* ⚡ **Gestión de Estado Robusta:** Control de estado reactivo y DI estructurado mediante **Riverpod**.
* 📍 **Lectura Fluida:** Guardado automático de la última lectura, tamaño de texto configurable y modos de visualización avanzados.

---

## 🛠️ Stack Tecnológico

| Componente             | Tecnología                          | Propósito                                             |
| ---------------------- | ------------------------------------ | ------------------------------------------------------ |
| **Framework**    | Flutter (Stable)                     | Desarrollo multiplataforma (Android/iOS)               |
| **Lenguaje**     | Dart                                 | Lenguaje tipado seguro y compilado a nativo            |
| **Estado + DI**  | `flutter_riverpod`                 | Inyección de dependencias y estado reactivo           |
| **Persistencia** | `drift` + `sqlite3_flutter_libs` | Base de datos SQLite reactiva con consultas estáticas |
| **Navegación**  | `go_router`                        | Enrutamiento declarativo estructurado                  |
| **Tema visual**  | `flex_color_scheme`                | Configuración estética Material 3 avanzada           |
| **Tipografía**  | `google_fonts`                     | Gestión premium de fuentes (Outfit / Inter / Lexend)  |

---

## 📂 Estructura del Proyecto (`lib/`)

```bash
lib/
├── core/               # Base de datos, temas, enrutador, utilidades y constantes
├── data/               # Fuentes de datos, repositorios concretos y modelos
├── domain/             # Entidades de negocio, interfaces de repositorio y casos de uso
├── presentation/       # Controladores (Providers), pantallas y componentes UI
└── l10n/               # Archivos ARB para internacionalización (i18n)
```

---

## 🚀 Empezando

### Requisitos Previos

* Flutter SDK instalado (Canal `stable`)
* Android SDK / Xcode configurado

### Instalación

1. **Clonar el repositorio:**

   ```bash
   git clone https://github.com/tu-usuario/51biblia.git
   cd 51biblia
   ```
2. **Obtener dependencias:**

   ```bash
   flutter pub get
   ```
3. **Generar código automático (Drift DB):**

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Ejecutar el proyecto:**

   ```bash
   flutter run
   ```

---

## 🛠️ Comandos de Desarrollo Comunes

* **Dar formato al código:** `dart format .`
* **Analizar código:** `flutter analyze`
* **Construir APK (Android):** `flutter build apk --split-per-abi`
* **Construir AppBundle (Android):** `flutter build appbundle`
* **Construir iOS sin firmar:** `flutter build ios --no-codesign`
