# Branding ERP Mobile — Recordatorios para agencias de branding

App móvil en **Flutter** que acompaña al ERP de branding. Muestra al usuario sus proyectos, sus recordatorios pendientes, las actividades del día y sus KPIs, y le avisa con **notificaciones push** (Firebase Cloud Messaging) y notificaciones locales programadas.

Forma parte de un sistema de tres repositorios:

| Repositorio | Rol |
|---|---|
| [Branding-ERP-WEB](https://github.com/Fabio0406/Branding-ERP-WEB) | ERP web (Spring Boot + Angular) |
| [Branding-ERP-Graphql-Server](https://github.com/Fabio0406/Branding-ERP-Graphql-Server) | Servidor GraphQL que consume esta app |
| **Branding-ERP-Mobile** (este) | App móvil de recordatorios |

> Proyecto académico — Ingeniería de Software II, UAGRM (2025).

## Funcionalidades

- **Inicio**: resumen con proyectos, recordatorios y KPIs.
- **Recordatorios**: listar, crear y marcar como vistos.
- **Proyectos**: estado de cada proyecto del usuario.
- **Notificaciones**: historial y registro de interacciones.
- Notificaciones push con FCM y notificaciones locales con zona horaria.
- Navegación inferior con GoRouter.

## Tecnologías

- Flutter (Dart ≥ 3.0)
- `graphql_flutter` — consultas, mutaciones y suscripciones
- `flutter_bloc` — manejo de estado
- `firebase_core`, `firebase_messaging`, `flutter_local_notifications`
- `go_router`, `shared_preferences`, `permission_handler`

## Estructura

```
lib/
├── main.dart                  # Arranque, Firebase y rutas
├── config/                    # Cliente GraphQL y consultas
├── bloc/recordatorios/        # BLoC de recordatorios
├── models/                    # Proyecto, Recordatorio, KPI, Marca, Cliente…
├── screens/                   # home, recordatorios, proyectos, notificaciones
├── services/                  # FCM y notificaciones locales
└── widgets/                   # tarjetas, diálogos y navegación
```

## Requisitos

- Flutter con Dart 3.0 o superior
- Un proyecto de Firebase
- El servidor [Branding-ERP-Graphql-Server](https://github.com/Fabio0406/Branding-ERP-Graphql-Server) en ejecución

## Cómo ejecutar

1. Tener corriendo el servidor [Branding-ERP-Graphql-Server](https://github.com/Fabio0406/Branding-ERP-Graphql-Server).
2. Cambiar la URL del servidor GraphQL en `lib/config/graphql_config.dart` (por defecto apunta a una IP de red local, `http://<ip>:4000/graphql`).
3. Configurar Firebase con `flutterfire configure` (genera `lib/firebase_options.dart` y `android/app/google-services.json`).
4. Ejecutar:

   ```bash
   flutter pub get
   flutter run
   ```
