// lib/models/proyecto.dart
import 'package:branding_erp_mobile/models/cliente.dart';
import 'package:branding_erp_mobile/models/etapa_proyecto.dart';
import 'package:branding_erp_mobile/models/kpi.dart';
import 'package:branding_erp_mobile/models/marca.dart';
import 'package:intl/intl.dart';

class Proyecto {
  final String id;
  final String nombre;
  final String? tipo;
  final DateTime? fechaInicio;
  final Cliente cliente;
  final Marca? marca;
  final List<EtapaProyecto> etapas;
  final List<KPI> kpis;

  Proyecto({
    required this.id,
    required this.nombre,
    this.tipo,
    this.fechaInicio,
    required this.cliente,
    this.marca,
    this.etapas = const [],
    this.kpis = const [],
  });

  factory Proyecto.fromJson(Map<String, dynamic> json) {
    return Proyecto(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      fechaInicio: json['fechaInicio'] != null 
          ? DateTime.parse(json['fechaInicio']) 
          : null,
      cliente: Cliente.fromJson(json['cliente']),
      marca: json['marca'] != null ? Marca.fromJson(json['marca']) : null,
      etapas: (json['etapas'] as List?)
          ?.map((e) => EtapaProyecto.fromJson(e))
          .toList() ?? [],
      kpis: (json['kpis'] as List?)
          ?.map((e) => KPI.fromJson(e))
          .toList() ?? [],
    );
  }

  String get fechaInicioFormateada => 
      fechaInicio != null ? DateFormat('dd/MM/yyyy').format(fechaInicio!) : 'Sin fecha';
}
