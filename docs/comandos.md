# Comandos Flutter — Biblia

## Emulador

```powershell
# Listar dispositivos disponibles
flutter devices

# Iniciar emulador Android (primero listar AVDs)
emulator -list-avds
emulator -avd <nombre_del_avd>

# Ej: emulator -avd Pixel_6_API_34
```

## Ejecutar

```powershell
# Android (emulador o físico)
flutter run

# Chrome (web)
flutter run -d chrome

# iOS (solo macOS)
flutter run -d ios

# Release mode
flutter run --release
```

## Build

```powershell
# APK (debug)
flutter build apk

# APK split por ABI (Play Store)
flutter build apk --split-per-abi

# App Bundle (Play Store)
flutter build appbundle

# iOS (sin code signing)
flutter build ios --no-codesign
```

## Calidad

```powershell
# Formatear código
dart format .

# Analizar errores/warnings
flutter analyze

# Generar código (drift/riverpod)
dart run build_runner build --delete-conflicting-outputs

# Generar código (modo watch)
dart run build_runner watch --delete-conflicting-outputs
```

## Limpiar

```powershell
flutter clean
flutter pub get
```
