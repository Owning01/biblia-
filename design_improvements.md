# Plan de Mejoras de Diseño y Corrección de Errores — App de la Biblia

Este documento detalla el análisis de la interfaz de usuario (UI) actual, la corrección de un error crítico de ejecución (crash) en la pantalla de configuración, y proporciona instrucciones precisas para tu **agente de IA de desarrollo**.

---

## 1. [CRÍTICO] Corrección del Crash en Configuración

### El Error:
`'dart:ui/painting.dart': Failed assertion: Text shadow blur radius should be non-negative.`

### Causa Raíz:
En `lib/presentation/screens/settings/settings_screen.dart`, el widget `_ColorPicker` utiliza un `AnimatedContainer` con la curva `Curves.easeOutBack` para animar la selección del esquema de colores. Cuando un color deja de estar seleccionado:
1. El `boxShadow` pasa de tener una sombra (`BoxShadow(blurRadius: 12, ...)`) a ser `null` (sin sombra).
2. Flutter interpola los valores de `blurRadius` de `12.0` a `0.0`.
3. Debido al efecto de retroceso/rebote de `Curves.easeOutBack`, la interpolación **sobrepasa (overshoots) el límite de 0.0**, produciendo un valor de radio negativo (por ejemplo, `-1.2`) a mitad de la animación.
4. Esto viola la aserción interna de Flutter que exige que los radios de sombra sean siempre no negativos, provocando la pantalla roja de error.

### Solución:
Cambiar la curva de animación del `AnimatedContainer` de la sombra por una que no tenga overshoot (como `Curves.easeOut` o `Curves.easeInOut`), o bien mantener el `boxShadow` siempre presente pero con opacidad `0` y `blurRadius: 0` para evitar interpolar a `null`. La solución más simple y robusta es cambiar la curva a `Curves.easeOut` o `Curves.easeInOut`.

---

## 2. Análisis de la UI y Puntos de Mejora

### 2.1 Pantalla de Inicio (`home_screen.dart`)
* **Estado actual**:
  * Utiliza un `Wrap` con `ActionChip` para listar los libros. Luce plano y genérico.
  * La tarjeta `_ContinueReadingCard` es un `Card` simple.
* **Propuesta Premium**:
  * Diseñar una cuadrícula interactiva para los libros con bordes redondeados (`borderRadius: BorderRadius.circular(16)`) y fondos de superficie sutiles.
  * Hacer el banner de continuación dinámico con un gradiente suave y tipografía `Outfit`.

### 2.2 Pantalla de Lectura (`bible_reader_screen.dart`)
* **Propuesta Premium**:
  * Ajustar márgenes a 24dp o 32dp horizontales y el interlineado a `1.5` o `1.6`.
  * Rediseñar las hojas inferiores (`ReadingConfigSheet`) con desenfoque de fondo (frosted glass).

### 2.3 Pantalla de Configuración (`settings_screen.dart`)
* **Propuesta Premium**:
  * Cambiar el `DropdownButton` nativo por un selector que abra un menú inferior elegante.
  * Corregir el componente `_SettingRow` (eliminar el caracter inválido `?trailing` y usar condicionales correctos de Dart como `if (trailing != null) trailing!`).

---

## 3. Instrucciones para tu Agente de IA

Copia y pega la siguiente instrucción a tu agente de desarrollo de IA para solucionar el crash e implementar las mejoras visuales:

> [!IMPORTANT]
> **Instrucciones para el Agente de Desarrollo:**
>
> 1. **Corrige el Crash de Animación**:
>    * Ubica el widget `_ColorPicker` en `lib/presentation/screens/settings/settings_screen.dart`.
>    * En el `AnimatedContainer`, cambia la propiedad `curve: Curves.easeOutBack` por `curve: Curves.easeOut` para evitar que la interpolación del `blurRadius` de la sombra genere valores negativos al sobrepasar el cero.
>
> 2. **Corrige el Error de Sintaxis**:
>    * En `_SettingRow` dentro de `lib/presentation/screens/settings/settings_screen.dart`, cambia el token inválido `?trailing` por un condicional Dart válido (ej. `if (trailing != null) trailing!,`).
>
> 3. **Aplica la Skill de Diseño Premium**:
>    * Rediseña las tarjetas, los selectores de fuente y de tamaño, y la cuadrícula de inicio aplicando fuentes de Google Fonts (como `Outfit` e `Inter`), márgenes amplios y esquemas cromáticos refinados usando tokens consistentes de `FlexColorScheme`.
