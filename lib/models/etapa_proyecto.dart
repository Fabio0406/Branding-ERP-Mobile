// lib/models/etapa_proyecto.dart
class EtapaProyecto {
  final String id;
  final String? descripcion;
  final DateTime? fechaLimite;
  final String? estado;
  final String? responsable;

  EtapaProyecto({
    required this.id,
    this.descripcion,
    this.fechaLimite,
    this.estado,
    this.responsable,
  });

  factory EtapaProyecto.fromJson(Map<String, dynamic> json) {
    return EtapaProyecto(
      id: json['id'],
      descripcion: json['descripcion'],
      fechaLimite: json['fechaLimite'] != null 
          ? DateTime.parse(json['fechaLimite']) 
          : null,
      estado: json['estado'],
      responsable: json['responsable'],
    );
  }
}