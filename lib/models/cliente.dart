// lib/models/cliente.dart
class Cliente {
  final String id;
  final String nombreEmpresa;
  final int? contacto;
  final String? sector;

  Cliente({
    required this.id,
    required this.nombreEmpresa,
    this.contacto,
    this.sector,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombreEmpresa: json['nombreEmpresa'],
      contacto: json['contacto'],
      sector: json['sector'],
    );
  }
}