// lib/services/notification_integration.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recordatorios/recordatorios_bloc.dart';
import '../bloc/recordatorios/recordatorios_event.dart';
import '../models/recordatorio.dart';
import 'notification_service.dart';

class NotificationIntegration {
  /// Programar notificación para un recordatorio
  static Future<void> scheduleRecordatorioNotification(Recordatorio recordatorio) async {
    try {
      // Calcular cuando enviar la notificación (5 minutos antes)
      final notificationTime = recordatorio.fechaRecordatorio.subtract(const Duration(minutes: 5));
      
      // Solo programar si la fecha es en el futuro
      if (notificationTime.isAfter(DateTime.now())) {
        final isUrgent = recordatorio.prioridad == PrioridadRecordatorio.urgente ||
                        recordatorio.esUrgente;
        
        final payload = {
          'type': 'recordatorio',
          'id': recordatorio.id,
          'urgent': isUrgent.toString(),
        };
        
        await NotificationService.scheduleRecordatorioNotification(
          id: recordatorio.id.hashCode,
          title: _getNotificationTitle(recordatorio),
          body: _getNotificationBody(recordatorio),
          scheduledDate: notificationTime,
          payload: payload.toString(),
          isUrgent: isUrgent,
        );
        
        if (kDebugMode) {
          print('📅 Notificación programada para ${recordatorio.titulo} a las ${notificationTime}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error programando notificación: $e');
      }
    }
  }

  /// Cancelar notificación de un recordatorio
  static Future<void> cancelRecordatorioNotification(String recordatorioId) async {
    try {
      await NotificationService.cancelNotification(recordatorioId.hashCode);
      
      if (kDebugMode) {
        print('🚫 Notificación cancelada para recordatorio: $recordatorioId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelando notificación: $e');
      }
    }
  }

  /// Mostrar notificación inmediata para recordatorio urgente
  static Future<void> showUrgentNotification(Recordatorio recordatorio) async {
    try {
      final payload = {
        'type': 'recordatorio',
        'id': recordatorio.id,
        'urgent': 'true',
      };
      
      await NotificationService.showImmediateNotification(
        title: '🚨 ${_getNotificationTitle(recordatorio)}',
        body: _getNotificationBody(recordatorio),
        payload: payload.toString(),
        isUrgent: true,
      );
      
      if (kDebugMode) {
        print('🚨 Notificación urgente mostrada para: ${recordatorio.titulo}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error mostrando notificación urgente: $e');
      }
    }
  }

  /// Programar notificaciones para una lista de recordatorios
  static Future<void> scheduleMultipleRecordatorios(List<Recordatorio> recordatorios) async {
    for (final recordatorio in recordatorios) {
      await scheduleRecordatorioNotification(recordatorio);
    }
  }

  /// Mostrar notificación de nuevo proyecto
  static Future<void> showProjectNotification({
    required String projectName,
    required String clientName,
    required String projectId,
  }) async {
    try {
      final payload = {
        'type': 'proyecto',
        'id': projectId,
      };
      
      await NotificationService.showImmediateNotification(
        title: 'Nuevo Proyecto Asignado',
        body: '$projectName para $clientName',
        payload: payload.toString(),
      );
      
      if (kDebugMode) {
        print('📋 Notificación de proyecto mostrada: $projectName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error mostrando notificación de proyecto: $e');
      }
    }
  }

  /// Generar título de notificación
  static String _getNotificationTitle(Recordatorio recordatorio) {
    switch (recordatorio.tipo) {
      case TipoRecordatorio.entrega:
        return 'Entrega Próxima';
      case TipoRecordatorio.reunion:
        return 'Reunión Programada';
      case TipoRecordatorio.aprobacion:
        return 'Aprobación Pendiente';
      case TipoRecordatorio.deadline:
        return 'Fecha Límite';
      case TipoRecordatorio.presentacion:
        return 'Presentación Programada';
      case TipoRecordatorio.seguimiento:
        return 'Seguimiento Requerido';
      default:
        return 'Recordatorio';
    }
  }

  /// Generar cuerpo de notificación
  static String _getNotificationBody(Recordatorio recordatorio) {
    final timeLeft = recordatorio.fechaRecordatorio.difference(DateTime.now());
    String timeText = '';
    
    if (timeLeft.inMinutes < 60) {
      timeText = 'en ${timeLeft.inMinutes} minutos';
    } else if (timeLeft.inHours < 24) {
      timeText = 'en ${timeLeft.inHours} horas';
    } else {
      timeText = 'en ${timeLeft.inDays} días';
    }
    
    String body = '${recordatorio.titulo} $timeText';
    
    if (recordatorio.proyecto != null) {
      body += ' - ${recordatorio.proyecto!.cliente.nombreEmpresa}';
    }
    
    return body;
  }
}

// Extensión para el BLoC de recordatorios
extension RecordatoriosBlocNotifications on RecordatoriosBloc {
  /// Programar notificaciones para recordatorios cargados
  void scheduleNotificationsForRecordatorios(List<Recordatorio> recordatorios) {
    NotificationIntegration.scheduleMultipleRecordatorios(recordatorios);
  }

  /// Manejar creación de recordatorio con notificación
  void createRecordatorioWithNotification(Recordatorio recordatorio) {
    // Añadir el recordatorio al estado
    add(CrearRecordatorio(recordatorio));
    
    // Programar la notificación
    NotificationIntegration.scheduleRecordatorioNotification(recordatorio);
  }

  /// Marcar recordatorio como visto y cancelar notificación
  void markRecordatorioVistedWithNotification(String recordatorioId) {
    // Marcar como visto
    add(MarcarRecordatorioVisto(recordatorioId));
    
    // Cancelar notificación programada
    NotificationIntegration.cancelRecordatorioNotification(recordatorioId);
  }
}