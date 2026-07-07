# 05 — Despliegue a Play Store y App Store

## Requisitos previos

| Plataforma | Requisito |
|---|---|
| Android | Cuenta de desarrollador Google Play ($25 USD, única vez) |
| iOS | Cuenta de desarrollador Apple ($99 USD/año) |

## Android — Play Store

### 1. Generar keystore

```powershell
# Crear keystore
keytool -genkey -v -keystore G:\Proyectos\51biblia\android\upload-keystore.jks `
  -storepass <contraseña> -alias upload `
  -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Configurar signing

Editar `android/key.properties` (NO subir a git):

```
storePassword=<contraseña>
keyPassword=<contraseña>
keyAlias=upload
storeFile=upload-keystore.jks
```

### 3. Configurar `android/app/build.gradle`

```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 4. Build + subir

```powershell
# Generar App Bundle
flutter build appbundle --release

# Subir a Play Console manualmente (o con fastlane)
# El AAB está en: build/app/outputs/bundle/release/app-release.aab
```

### 5. Play Console

- Crear app → llenar ficha (nombre, descripción, categoría: Religión)
- Subir AAB → rellenar "App Content" (política de privacidad, calificación)
- Pricing & Distribution → gratis, todos los países
- Publicar

## iOS — App Store

### 1. Xcode project

```powershell
# Abrir en Xcode
open ios/Runner.xcworkspace
```

- Cambiar Bundle Identifier en Signing & Capabilities
- Seleccionar Team (cuenta de desarrollador Apple)
- Cambiar nombre en Identity

### 2. Build

```powershell
# Clean
flutter clean && flutter pub get

# Build iOS
flutter build ios --release --no-codesign

# Archivar en Xcode:
# Product → Archive → Upload to App Store Connect
```

### 3. App Store Connect

- Rellenar ficha (nombre, descripción, keywords)
- Privacidad: enlace a política
- Calificación: 4+
- Capturas de pantalla (6.5" y 5.5" iPhone + iPad)
- Subir build → TestFlight → submit for review

## Fastlane (opcional — CI/CD)

```ruby
# fastlane/Fastfile
lane :beta do
  build_app
  upload_to_play_store(track: 'internal')
end

lane :release do
  build_app
  upload_to_app_store
end
```

## Checklist pre-lanzamiento

- [ ] Política de privacidad creada y enlazada
- [ ] Calificación de contenido (4+ / Everyone)
- [ ] Screenshots: 6.5" + 5.5" iPhone, Android 7"+10" tablet
- [ ] Feature graphic (1024x500) para Play Store
- [ ] App icon (adaptativo Android, iOS)
- [ ] Sin crashes en `flutter analyze`
- [ ] Test en dispositivo físico Android + iOS
- [ ] Proguard rules configuradas
- [ ] Versión actualizada en pubspec.yaml
- [ ] `dart format .` ejecutado

## Política de privacidad

```
Biblia — Política de Privacidad
Última actualización: [Fecha]

Biblia no recopila, almacena ni comparte información personal del usuario.
Todos los datos (marcadores, notas, subrayados, progreso de lectura)
se almacenan exclusivamente en el dispositivo del usuario.

No se utilizan servicios de análisis, anuncios ni seguimiento de terceros.

Si se implementan características cloud en el futuro,
se actualizará esta política y se solicitará consentimiento explícito.

Contacto: [email]
```
