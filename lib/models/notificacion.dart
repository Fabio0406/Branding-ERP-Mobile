// lib/models/notificacion.dart
import 'proyecto.dart';

enum TipoNotificacion {
  nuevoProyecto,
  cambioEstado,
  aprobacionPendiente,
  entregaProxima,
  reunionProgramada,
  tareaAsignada,
}

class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final bool leida;
  final DateTime fecha;
  final Proyecto? proyecto;
  final String? accionUrl;
  final String? interaccion;
  final DateTime? fechaInteraccion;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.leida,
    required this.fecha,
    this.proyecto,
    this.accionUrl,
    this.interaccion,
    this.fechaInteraccion,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    try {
      return Notificacion(
        id: json['id']?.toString() ?? '',
        titulo: json['titulo']?.toString() ?? 'Sin título',
        mensaje: json['mensaje']?.toString() ?? 'Sin mensaje',
        tipo: _parseTipoNotificacion(json['tipo']),
        leida: json['leida'] ?? false,
        fecha: _parseDateTime(json['fecha']),
        proyecto: json['proyecto'] != null 
            ? Proyecto.fromJson(json['proyecto'] as Map<String, dynamic>)
            : null,
        accionUrl: json['accionUrl']?.toString(),
        interaccion: json['interaccion']?.toString(),
        fechaInteraccion: json['fechaInteraccion'] != null 
            ? DateTime.tryParse(json['fechaInteraccion'].toString())
            : null,
      );
    } catch (e) {
      print('❌ Error parsing Notificacion: $e');
      print('📋 JSON data: $json');
      
      // Retornar notificación por defecto en caso de error
      return Notificacion(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: 'Error en notificación',
        mensaje: 'Hubo un problema al cargar esta notificación',
        tipo: TipoNotificacion.tareaAsignada,
        leida: false,
        fecha: DateTime.now(),
      );
    }
  }

  static TipoNotificacion _parseTipoNotificacion(dynamic tipo) {
    if (tipo == null) return TipoNotificacion.tareaAsignada;
    
    final tipoStr = tipo.toString().toUpperCase();
    
    switch (tipoStr) {
      case 'NUEVO_PROYECTO':
        return TipoNotificacion.nuevoProyecto;
      case 'CAMBIO_ESTADO':
        return TipoNotificacion.cambioEstado;
      case 'APROBACION_PENDIENTE':
        return TipoNotificacion.aprobacionPendiente;
      case 'ENTREGA_PROXIMA':
        return TipoNotificacion.entregaProxima;
      case 'REUNION_PROGRAMADA':
        return TipoNotificacion.reunionProgramada;
      case 'TAREA_ASIGNADA':
        return TipoNotificacion.tareaAsignada;
      default:
        print('⚠️ Tipo de notificación desconocido: $tipo');
        return TipoNotificacion.tareaAsignada;
    }
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    
    if (dateTime is DateTime) return dateTime;
    
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        print('⚠️ Error parsing datetime: $dateTime - $e');
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }

  String get fechaFormateada {
    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  String get tipoLabel {
    switch (tipo) {
      case TipoNotificacion.nuevoProyecto:
        return 'Nuevo Proyecto';
      case TipoNotificacion.cambioEstado:
        return 'Cambio de Estado';
      case TipoNotificacion.aprobacionPendiente:
        return 'Aprobación Pendiente';
      case TipoNotificacion.entregaProxima:
        return 'Entrega Próxima';
      case TipoNotificacion.reunionProgramada:
        return 'Reunión Programada';
      case TipoNotificacion.tareaAsignada:
        return 'Tarea Asignada';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo.toString().split('.').last.toUpperCase(),
      'leida': leida,
      'fecha': fecha.toIso8601String(),
      'proyecto': proyecto,
      'accionUrl': accionUrl,
      'interaccion': interaccion,
      'fechaInteraccion': fechaInteraccion?.toIso8601String(),
    };
  }

  Notificacion copyWith({
    String? id,
    String? titulo,
    String? mensaje,
    TipoNotificacion? tipo,
    bool? leida,
    DateTime? fecha,
    Proyecto? proyecto,
    String? accionUrl,
    String? interaccion,
    DateTime? fechaInteraccion,
  }) {
    return Notificacion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      leida: leida ?? this.leida,
      fecha: fecha ?? this.fecha,
      proyecto: proyecto ?? this.proyecto,
      accionUrl: accionUrl ?? this.accionUrl,
      interaccion: interaccion ?? this.interaccion,
      fechaInteraccion: fechaInteraccion ?? this.fechaInteraccion,
    );
  }

  @override
  String toString() {
    return 'Notificacion{id: $id, titulo: $titulo, tipo: $tipo, leida: $leida}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notificacion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}