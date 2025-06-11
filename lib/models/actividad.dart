// lib/models/actividad.dart
import 'package:branding_erp_mobile/models/proyecto.dart';
import 'package:intl/intl.dart';

enum TipoActividad {
  reunion,
  entrega,
  revision,
  presentacion,
  trabajoInterno,
  aprobacion,
}

class Actividad {
  final String id;
  final String titulo;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final TipoActividad tipo;
  final Proyecto? proyecto;

  Actividad({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    required this.tipo,
    this.proyecto,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: json['fechaFin'] != null 
          ? DateTime.parse(json['fechaFin']) 
          : null,
      tipo: TipoActividad.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == 
              json['tipo'].toString().replaceAll('_', '').toUpperCase(),
      ),
      proyecto: json['proyecto'] != null 
          ? Proyecto.fromJson(json['proyecto']) 
          : null,
    );
  }

  String get horaInicio => DateFormat('HH:mm').format(fechaInicio);
  String get horaFin => fechaFin != null ? DateFormat('HH:mm').format(fechaFin!) : '';
  
  Duration? get duracion => fechaFin?.difference(fechaInicio);
}