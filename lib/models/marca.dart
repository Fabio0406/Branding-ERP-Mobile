// lib/models/marca.dart
class Marca {
  final String id;
  final String nombre;
  final String? sector;
  final String? estado;

  Marca({
    required this.id,
    required this.nombre,
    this.sector,
    this.estado,
  });

  factory Marca.fromJson(Map<String, dynamic> json) {
    return Marca(
      id: json['id'],
      nombre: json['nombre'],
      sector: json['sector'],
      estado: json['estado'],
    );
  }
}