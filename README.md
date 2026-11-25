# Práctica 12 – Permisos en Flutter (Equipo 1, Grupo C)

**Integrantes:** Melendez Aguilera Jonathan Nicolas · Ayala Canul Jorge Carlos · Narvaez Avila Josue Leví · Yah Palma Angel Gabriel

Módulos asignados al Equipo 1: **1.1 Calendario**, **1.3 Contactos**, **1.11 Storage**.

| Módulo | Qué hace la app | Paquetes |
|---|---|---|
| 1.1 Calendario | Pide permiso, lista eventos (30 días), crea un evento de prueba | `permission_handler`, `device_calendar` |
| 1.3 Contactos | Pide permiso, lista contactos, crea un contacto de prueba | `permission_handler`, `flutter_contacts` |
| 1.11 Storage | Pide permiso, guarda/lee una nota `.txt` y prueba el almacenamiento compartido | `permission_handler`, `path_provider`, `device_info_plus` |

> **Android 13+:** `READ_EXTERNAL_STORAGE` ya no existe; la app detecta el SDK y pide `READ_MEDIA_IMAGES` (Permission.photos). En Android ≤ 12 pide `Permission.storage`.

## Arquitectura

- `PermissionGate` (widget): consulta el estado, muestra el botón *Solicitar permiso* o *Abrir ajustes* (denegado permanente) y re-consulta al volver de Ajustes.
- `PermissionGateway` / `*Repository`: interfaces con implementación **real** (Android) y **simulada** (Chrome y pruebas).
- En **Chrome** (`kIsWeb`) se usa la versión simulada, con un banner amarillo. Calendario, contactos y permisos de almacenamiento reales **no existen en navegador**; Chrome sirve para probar la UI y el flujo, no los permisos reales.

## 1. Preparar el proyecto (una sola vez)

Requiere Flutter SDK instalado (`flutter doctor`).

```bash
cd permisos_equipo1
flutter create --platforms=android,web --org mx.edu.utm.equipo1 .
```

Luego:

1. Borra el test de ejemplo que genera Flutter, si existe: `test/widget_test.dart`.
2. Copia el manifest con los permisos sobre el generado:
   - Copia `android_manifest/AndroidManifest.xml` a `android/app/src/main/AndroidManifest.xml` (reemplazar).
3. Instala dependencias:

```bash
flutter pub get
```

## 2. Probar en Chrome (ahora)

```bash
flutter run -d chrome
```

Flujo: entra a cada módulo → *Solicitar permiso* → usa los botones. Los datos son simulados.

## 3. Ejecutar las pruebas

```bash
flutter analyze
flutter test                 # todas
flutter test test/permission_gateway_test.dart
flutter test test/repositories_test.dart
flutter test test/app_widget_test.dart
flutter test --coverage      # opcional
```

Cubren: mapeo de estados del plugin, gateway simulado, repositorios (calendario/contactos/storage), flujo del `PermissionGate` (denegado → solicitar → concedido, rechazo, denegado permanente) y cada pantalla.

## 4. Ejecutar en Android (dispositivo físico)

1. En el teléfono: Ajustes → Opciones de desarrollador → activar **Depuración USB**.
2. Conéctalo y verifica: `flutter devices`
3. Ejecuta:

```bash
flutter run -d <id-del-dispositivo>
# o genera el APK:
flutter build apk --debug
```

### Checklist manual en el dispositivo (evidencia para el Word)

| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | Abrir 1.1 con permiso sin conceder | Estado *Denegado* + botón *Solicitar permiso* |
| 2 | Tocar *Solicitar permiso* → **Permitir** | Estado *Concedido* y lista de eventos |
| 3 | *Crear evento de prueba* | Aparece «Entrega práctica 12 - Equipo 1»; verificar en la app Calendario |
| 4 | Repetir 1–3 con 1.3 | Lista de contactos; se crea «Demo Equipo 1»; verificar en Contactos |
| 5 | Repetir 1–2 con 1.11 | Estado *Concedido* |
| 6 | Escribir texto → *Guardar nota* → tocar el archivo | Se muestra el contenido guardado |
| 7 | *Probar almacenamiento compartido* | Mensaje OK o «Sin acceso» (en Android 11+ es normal por scoped storage) |
| 8 | Denegar dos veces un permiso | Aparece *Abrir ajustes*; conceder desde Ajustes y volver: se actualiza solo |

### Capturas

Toma capturas **reales** de tu ejecución (pasos 1, 2, 3, 6 y 8 como mínimo por módulo):

```bash
adb exec-out screencap -p > cap_1_1_calendario_01.png
```

En Chrome puedes capturar con DevTools (Ctrl+Shift+P → "Capture screenshot"). Indica en el documento cuáles son de Chrome (simulado) y cuáles del dispositivo físico: la práctica pide evidencia en dispositivo Android.

## Problemas frecuentes

- **Error de Gradle / `namespace`** en algún plugin: `flutter pub upgrade` y volver a compilar.
- **`minSdkVersion`**: en `android/app/build.gradle(.kts)` usa `minSdk = 21` o superior si el plugin lo pide.
- **El diálogo de permiso ya no sale**: se denegó permanentemente; usa *Abrir ajustes* o desinstala la app.
- **Sin calendario editable**: el teléfono necesita una cuenta de Google o un calendario local.
- **Las pruebas fallan al importar paquetes**: ejecuta primero `flutter pub get`.

## Referencias sugeridas (APA, faltan dos para el mínimo de tres)

- freeCodeCamp. (s. f.). *How to handle permissions in Flutter for beginners*. https://www.freecodecamp.org/news/how-to-handle-permissions-in-flutter-forbeginners/
- Pub.dev. (s. f.). *permission_handler*. https://pub.dev/packages/permission_handler
- Pub.dev. (s. f.). *device_calendar* y *flutter_contacts*. https://pub.dev/packages/device_calendar · https://pub.dev/packages/flutter_contacts
