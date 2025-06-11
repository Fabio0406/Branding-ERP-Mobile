// lib/models/kpi.dart
class KPI {
  final String id;
  final String? tipo;
  final double? valor;
  final String? periodo;
  final DateTime? fechaRegistro;

  KPI({
    required this.id,
    this.tipo,
    this.valor,
    this.periodo,
    this.fechaRegistro,
  });

  factory KPI.fromJson(Map<String, dynamic> json) {
    return KPI(
      id: json['id'],
      tipo: json['tipo'],
      valor: json['valor']?.toDouble(),
      periodo: json['periodo'],
      fechaRegistro: json['fechaRegistro'] != null 
          ? DateTime.parse(json['fechaRegistro']) 
          : null,
    );
  }
}