// lib/services/firebase_messaging_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

// Manejador de notificaciones en background (debe estar fuera de la clase)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📱 Handling a background message: ${message.messageId}');
  }
  
  // Procesar la notificación en background
  await FirebaseMessagingService._handleBackgroundMessage(message);
}

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;
  static BuildContext? _context;

  static Future<void> initialize({BuildContext? context}) async {
    _context = context;
    
    try {
      // 1. Solicitar permisos
      await _requestPermissions();
      
      // 2. Obtener y guardar token FCM
      await _initializeToken();
      
      // 3. Configurar manejadores de mensajes
      _setupMessageHandlers();
      
      // 4. Configurar manejo de token refresh
      _setupTokenRefresh();
      
      // 5. Verificar mensaje inicial
      await _checkInitialMessage();
      
      if (kDebugMode) {
        print('✅ Firebase Messaging inicializado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inicializando Firebase Messaging: $e');
      }
    }
  }

  /// Solicitar permisos de notificación
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('✅ Usuario autorizó las notificaciones');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('⚠️ Usuario otorgó permisos provisionales');
      }
    } else {
      if (kDebugMode) {
        print('❌ Usuario denegó las notificaciones');
      }
    }
  }

  /// Inicializar y guardar token FCM
  static Future<void> _initializeToken() async {
    _fcmToken = await _messaging.getToken();
    if (_fcmToken != null) {
      await _saveFCMToken(_fcmToken!);
      if (kDebugMode) {
        print('🔑 FCM Token obtenido: $_fcmToken');
      }
      
      // Aquí puedes enviar el token a tu servidor
      await _sendTokenToServer(_fcmToken!);
    }
  }

  /// Configurar refresh de token
  static void _setupTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      await _saveFCMToken(newToken);
      await _sendTokenToServer(newToken);
      
      if (kDebugMode) {
        print('🔄 Token FCM actualizado: $newToken');
      }
    });
  }

  /// Configurar manejadores de mensajes
  static void _setupMessageHandlers() {
    // Configurar handler para background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Mensaje recibido cuando la app está en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Mensaje tocado cuando la app está en background pero no terminada
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Verificar mensaje inicial (cuando la app se abre desde una notificación)
  static Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('📱 App iniciada desde notificación: ${initialMessage.messageId}');
      }
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Manejar mensaje en foreground
  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📱 Mensaje recibido en foreground: ${message.notification?.title}');
    }
    
    // Determinar si es urgente
    final isUrgent = message.data['priority'] == 'urgent' || 
                    message.data['type'] == 'urgent';
    
    // Mostrar notificación local cuando la app está en primer plano
    NotificationService.mostrarNotificacionInmediata(
      titulo: message.notification?.title ?? 'Nueva notificación',
      mensaje: message.notification?.body ?? '',
      payload: message.data['recordatorio_id'],
      isUrgent: isUrgent,
    );
  }

  /// Manejar cuando la app se abre desde una notificación
  static void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('📱 App abierta desde notificación: ${message.notification?.title}');
    }
    
    // Navegar según el tipo de notificación
    _navigateFromNotification(message.data);
  }

  /// Manejar mensaje en background
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📱 Mensaje recibido en background: ${message.notification?.title}');
    }
    
    // Los mensajes en background se manejan automáticamente por el sistema
    // Aquí puedes procesar datos adicionales si es necesario
  }

  /// Navegar desde notificación
  static void _navigateFromNotification(Map<String, dynamic> data) {
    if (_context == null) return;

    final type = data['type'] as String?;
    final id = data['id'] as String?;
    final recordatorioId = data['recordatorio_id'] as String?;

    // Usar GoRouter para navegar
    switch (type) {
      case 'recordatorio':
        GoRouter.of(_context!).go('/recordatorios');
        break;
      case 'proyecto':
        if (id != null) {
          GoRouter.of(_context!).go('/proyectos'); // Podrías pasar el ID como query param
        } else {
          GoRouter.of(_context!).go('/proyectos');
        }
        break;
      case 'urgent':
        GoRouter.of(_context!).go('/recordatorios'); // Podrías filtrar por urgentes
        break;
      case 'notificacion':
        GoRouter.of(_context!).go('/notificaciones');
        break;
      default:
        GoRouter.of(_context!).go('/');
    }
  }

  /// Suscribirse a un topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('✅ Suscrito al topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error suscribiendo al topic $topic: $e');
      }
    }
  }

  /// Desuscribirse de un topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('✅ Desuscrito del topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error desuscribiendo del topic $topic: $e');
      }
    }
  }

  /// Guardar token FCM localmente
  static Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando token FCM: $e');
      }
    }
  }

  /// Obtener token FCM guardado
  static Future<String?> getSavedFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo token FCM guardado: $e');
      }
      return null;
    }
  }

  /// Enviar token al servidor (implementar según tu backend)
  static Future<void> _sendTokenToServer(String token) async {
    try {
      // Aquí deberías implementar el envío del token a tu servidor GraphQL
      // Por ejemplo:
      /*
      final mutation = '''
        mutation UpdateUserFCMToken(\$token: String!) {
          updateUserFCMToken(token: \$token) {
            success
          }
        }
      ''';
      
      await GraphQLConfig.client.value.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {'token': token},
        ),
      );
      */
      
      if (kDebugMode) {
        print('📤 Token FCM enviado al servidor (implementar)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error enviando token al servidor: $e');
      }
    }
  }

  /// Obtener token FCM actual
  static String? get fcmToken => _fcmToken;

  /// Suscribirse a topics básicos del usuario
  static Future<void> subscribeToUserTopics(String userId) async {
    await subscribeToTopic('user_$userId');
    await subscribeToTopic('recordatorios');
    await subscribeToTopic('proyectos');
  }

  /// Desuscribirse de topics del usuario
  static Future<void> unsubscribeFromUserTopics(String userId) async {
    await unsubscribeFromTopic('user_$userId');
    await unsubscribeFromTopic('recordatorios');
    await unsubscribeFromTopic('proyectos');
  }

  /// Actualizar contexto de navegación
  static void updateContext(BuildContext context) {
    _context = context;
  }
}