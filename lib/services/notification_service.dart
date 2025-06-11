// lib/services/notification_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class AppColors {
  static const Color darkNavy = Color(0xFF0D1321);
  static const Color navy = Color(0xFF1D2D44);
  static const Color blueGray = Color(0xFF3E5C76);
  static const Color lightBlue = Color(0xFF748CAB);
  static const Color cream = Color(0xFFF0EDD8);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  static BuildContext? _context;

  /// Inicializar el servicio de notificaciones locales
  static Future<void> initialize({BuildContext? context}) async {
    _context = context;
    
    try {
      // Configurar notificaciones locales
      await _initializeLocalNotifications();
      
      if (kDebugMode) {
        print('✅ NotificationService inicializado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inicializando NotificationService: $e');
      }
    }
  }

  /// Configurar notificaciones locales
  static Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificación para Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Crear canales de notificación para Android
  static Future<void> _createNotificationChannels() async {
    const recordatoriosChannel = AndroidNotificationChannel(
      'recordatorios_channel',
      'Recordatorios',
      description: 'Notificaciones de recordatorios y tareas',
      importance: Importance.high,
      ledColor: AppColors.blueGray,
    );

    var urgentesChannel = AndroidNotificationChannel(
      'urgentes_channel',
      'Urgentes',
      description: 'Notificaciones urgentes que requieren atención inmediata',
      importance: Importance.max,
      ledColor: AppColors.error,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    const proyectosChannel = AndroidNotificationChannel(
      'proyectos_channel',
      'Proyectos',
      description: 'Notificaciones relacionadas con proyectos',
      importance: Importance.high,
      ledColor: AppColors.info,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(recordatoriosChannel);
        
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(urgentesChannel);
        
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(proyectosChannel);
  }

  /// Manejar toque en notificación local
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationTap(data);
      } catch (e) {
        if (kDebugMode) {
          print('Error procesando payload de notificación: $e');
        }
      }
    }
  }

  /// Manejar toque en notificación (navegación)
  static void _handleNotificationTap(Map<String, dynamic> data) {
    if (_context == null) return;

    final type = data['type'] as String?;
    final id = data['id'] as String?;

    // Navegar según el tipo de notificación
    switch (type) {
      case 'recordatorio':
        // Navegar a recordatorios
        if (_context!.mounted) {
          // Aquí puedes usar GoRouter para navegar
          // context.go('/recordatorios');
        }
        break;
      case 'proyecto':
        // Navegar a proyectos específico
        if (_context!.mounted) {
          // context.go('/proyectos/$id');
        }
        break;
      case 'urgent':
        // Navegar a recordatorios urgentes
        if (_context!.mounted) {
          // context.go('/recordatorios?filter=urgent');
        }
        break;
      default:
        // Navegar al dashboard
        if (_context!.mounted) {
          // context.go('/');
        }
    }
  }

  /// Programar notificación local para recordatorio
  static Future<void> scheduleRecordatorioNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool isUrgent = false,
  }) async {
    final channelId = isUrgent ? 'urgentes_channel' : 'recordatorios_channel';
    final color = isUrgent ? AppColors.error : AppColors.blueGray;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: isUrgent ? Importance.max : Importance.high,
      priority: isUrgent ? Priority.max : Priority.high,
      color: color,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convertir DateTime a TZDateTime para La Paz, Bolivia
    final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.getLocation('America/La_Paz'));

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    if (kDebugMode) {
      print('📅 Notificación programada: $title para ${scheduledTZ}');
    }
  }

  /// Cancelar notificación programada
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    if (kDebugMode) {
      print('🚫 Notificación cancelada: $id');
    }
  }

  /// Cancelar todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    if (kDebugMode) {
      print('🚫 Todas las notificaciones canceladas');
    }
  }

  /// Mostrar notificación inmediata
  static Future<void> mostrarNotificacionInmediata({
    required String titulo,
    required String mensaje,
    String? payload,
    bool isUrgent = false,
  }) async {
    final channelId = isUrgent ? 'urgentes_channel' : 'recordatorios_channel';
    final color = isUrgent ? AppColors.error : AppColors.blueGray;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: isUrgent ? Importance.max : Importance.high,
      priority: isUrgent ? Priority.max : Priority.high,
      color: color,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        mensaje,
        contentTitle: titulo,
        summaryText: 'Branding ERP',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      titulo,
      mensaje,
      notificationDetails,
      payload: payload,
    );

    if (kDebugMode) {
      print('📱 Notificación inmediata mostrada: $titulo');
    }
  }

  /// Mostrar notificación inmediata (alias para compatibilidad)
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
    bool isUrgent = false,
  }) async {
    await mostrarNotificacionInmediata(
      titulo: title,
      mensaje: body,
      payload: payload,
      isUrgent: isUrgent,
    );
  }

  /// Helpers para nombres de canales
  static String _getChannelName(String channelId) {
    switch (channelId) {
      case 'urgentes_channel':
        return 'Urgentes';
      case 'proyectos_channel':
        return 'Proyectos';
      default:
        return 'Recordatorios';
    }
  }

  static String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'urgentes_channel':
        return 'Notificaciones urgentes que requieren atención inmediata';
      case 'proyectos_channel':
        return 'Notificaciones relacionadas con proyectos';
      default:
        return 'Notificaciones de recordatorios y tareas';
    }
  }

  /// Obtener notificaciones pendientes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Verificar si las notificaciones están habilitadas
  static Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true; // En iOS asumimos que están habilitadas si llegamos aquí
  }

  /// Solicitar permisos de notificación (Android 13+)
  static Future<bool> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.requestNotificationsPermission() ?? false;
    }
    return true;
  }
}