# 04 — Funcionalidades Completas

## 1. Navegación Biblia

- **Selector de libros**: lista con search, dividida en AT y NT
- **Selector de capítulos**: grid numerado por libro
- **Lector**: scroll vertical con todos los versículos del capítulo
  - Swipe horizontal para capítulo anterior/siguiente
  - Número de versículo a la izquierda, texto a la derecha
  - Tap en un versículo → bottom sheet con acciones
  - Long-press para seleccionar rango de versículos

## 2. Multi-versión

- Switcher rápido desde el lector (dropdown o bottom sheet)
- Hasta N versiones instaladas simultáneamente
- Cada versión con su propio copyright/licencia visible
- Descarga de nuevas versiones desde settings

## 3. Búsqueda

- Barra de búsqueda global con resultados en tiempo real
- Parser de referencias:
  - `Juan` → mostrar capítulos del libro
  - `Juan 3` → ir al capítulo
  - `Juan 3:16` → ir al versículo exacto
  - `Juan 3:16-21` → rango
  - `Juan 3:16 amor` → búsqueda contextual
- FTS5 para búsqueda full-text (funciona offline):
  - Frases exactas: `"en el principio"`
  - Múltiples términos: `amor paciencia fe`
- Resultados agrupados por libro
- Snippets con el match resaltado
- Historial de búsquedas recientes

## 4. Marcadores

- Lista de marcadores agrupados por libro
- Tap para navegar al versículo
- Swipe para eliminar
- Opción de agregar etiqueta/label

## 5. Subrayado (Highlights)

- 6 colores disponibles: amarillo, verde, azul, rosa, naranja, morado
- Tap en versículo → highlight toggle
- Vista de todos los highlights filtrables por color
- Tap en highlight → navegar al versículo

## 6. Notas

- Editor de texto libre vinculado a un versículo o rango
- Timestamp de creación/actualización
- Lista cronológica de todas las notas
- Preview del versículo asociado

## 7. Compartir

### Como texto
```
"Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito..."
— Juan 3:16 (Reina Valera 1960)
```

### Como imagen
- Widget renderizado con:
  - Fondo: gradiente personalizable o sólido
  - Fuente seleccionada por el usuario
  - Tamaño de letra ajustable
  - Versículo centrado + referencia abajo
- Captura a PNG con `screenshot` package
- Share sheet nativo del SO

## 8. Planes de lectura

- Planes precargados:
  - La Biblia en 1 Año
  - Los Evangelios en 30 Días
  - Salmos y Proverbios en 60 Días
  - Nuevo Testamento en 90 Días
- Check diario de progreso
- Notificaciones diarias recordatorias
- Estadísticas: días completados, porcentaje

## 9. Historial

- Últimos N capítulos visitados
- Timestamp de última visita
- Tap para continuar leyendo

## 10. Personalización

### Temas (3 modos)

| Modo | Fondo | Texto | Ideal para |
|---|---|---|---|
| Claro | Blanco #FFFFFF | Negro #1A1A1A | Día |
| Oscuro | Negro #121212 | Gris claro #E0E0E0 | Noche |
| Sepia | #F5E6C8 | #5C3A1E | Lectura extendida |

### Fuentes

| Fuente | Estilo | Uso |
|---|---|---|
| Inter | Sans-serif | UI general |
| Noto Serif | Serif | Lectura de versículos |
| Lora | Serif elegante | Lectura |
| JetBrains Mono | Monoespaciada | Estudio/paralelo |

### Tamaño de letra
- Slider o presets: 12–28 sp
- Persistido en SharedPreferences

## 11. Offline-first

- RV1960 embebida en el APK (~4 MB comprimido)
- Versiones adicionales descargables bajo demanda
- Todo funciona sin conexión
- Sincronización opcional futura (iCloud / Drive)
