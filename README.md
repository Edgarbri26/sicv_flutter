# SICV Flutter

Aplicación cliente Flutter del sistema de inventario (sicv).

## Descripción

Este repositorio contiene la aplicación móvil/desktop/web desarrollada con Flutter que consume la API de inventario. Incluye integración con Firebase (autenticación, opciones) y está estructurada para soportar Android, iOS, web y Windows/macOS/Linux.

## Características
- Autenticación (Firebase / backend REST)
- Manejo de productos, proveedores, inventarios y ventas
- Interfaz adaptativa para móviles y escritorio

## Requisitos previos
- Flutter 3.0+ instalado y configurado: https://docs.flutter.dev/get-started/install
- SDKs de plataforma (Android SDK / Xcode para iOS) según la plataforma destino
- (Opcional) Cuenta y proyecto en Firebase si vas a usar funcionalidades relacionadas

## Configuración rápida (Windows / PowerShell)

1. Clona el repositorio y sitúate en la carpeta del cliente:

```powershell
git clone <repo-url>
cd "c:\dev\Inventario App\sicv_flutter"
```

2. Instala dependencias de Dart/Flutter:

```powershell
flutter pub get
```

3. (Si usas Firebase) Asegúrate de tener `firebase_options.dart` generado en `lib/`.
	 - Si falta, genera el archivo usando FlutterFire CLI según la configuración de tu proyecto Firebase.

## Ejecutar la app

- En modo debug en el emulador/dispositivo conectado:

```powershell
flutter run
```

- Ejecutar para web (por ejemplo chrome):

```powershell
flutter run -d chrome
```

- Ejecutar para Windows (si la plataforma está habilitada):

```powershell
flutter run -d windows
```

## Generar build de producción

- Android (APK / app bundle):

```powershell
flutter build apk --release
flutter build appbundle --release
```

- iOS (desde macOS con Xcode instalado):

```powershell
flutter build ios --release
```

- Web:

```powershell
flutter build web --release
```

## Firebase

- El proyecto ya incluye `firebase_options.dart`. Si necesitas regenerarlo:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

- Revisa `lib/firebase_options.dart` y `lib/main.dart` para ver cómo se inicializa Firebase.

## Estructura de carpetas (resumen)

- `lib/` - Código fuente Flutter (entrada: `main.dart` o `app.dart`)
	- `config/`, `core/`, `models/`, `providers/`, `services/`, `ui/` — organización por capas
- `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/` - carpetas de plataforma


## Consejos y pasos siguientes recomendados
- Añadir badges (build, test, codecov) en el README raíz.
- Documentar cómo correr la API backend localmente y la URL base que consume la app.
- Mantener en `.env` o en configuración segura las claves de API / Firebase cuando corresponda.

## Licencia

Este proyecto sigue la licencia del repositorio principal. Revisa el archivo `LICENSE` en la raíz.

---

Si quieres, traduzco este README al inglés, añado badges, o incluyo un apartado específico para contribución y CI/CD.
