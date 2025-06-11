// lib/models/recordatorio.dart
import 'package:branding_erp_mobile/models/proyecto.dart';
import 'package:intl/intl.dart';

enum TipoRecordatorio {
  entrega,
  reunion,
  aprobacion,
  seguimiento,
  deadline,
  presentacion,
}

enum PrioridadRecordatorio {
  baja,
  media,
  alta,
  urgente,
}

class Recordatorio {
  final String id;
  final String titulo;
  final String? descripcion;
  final DateTime fechaRecordatorio;
  final TipoRecordatorio tipo;
  final PrioridadRecordatorio prioridad;
  final bool visto;
  final Proyecto? proyecto;
  final DateTime createdAt;

  Recordatorio({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.fechaRecordatorio,
    required this.tipo,
    required this.prioridad,
    required this.visto,
    this.proyecto,
    required this.createdAt,
  });

  factory Recordatorio.fromJson(Map<String, dynamic> json) {
    return Recordatorio(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaRecordatorio: DateTime.parse(json['fechaRecordatorio']),
      tipo: TipoRecordatorio.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['tipo'],
      ),
      prioridad: PrioridadRecordatorio.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['prioridad'],
      ),
      visto: json['visto'] ?? false,
      proyecto: json['proyecto'] != null 
          ? Proyecto.fromJson(json['proyecto']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get fechaFormateada => DateFormat('dd/MM/yyyy HH:mm').format(fechaRecordatorio);
  
  String get tiempoRestante {
    final now = DateTime.now();
    final difference = fechaRecordatorio.difference(now);
    
    if (difference.isNegative) {
      return 'Vencido';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas';
    } else {
      return '${difference.inMinutes} minutos';
    }
  }

  bool get esUrgente => 
      prioridad == PrioridadRecordatorio.urgente ||
      (prioridad == PrioridadRecordatorio.alta && 
       fechaRecordatorio.difference(DateTime.now()).inHours < 24);
}