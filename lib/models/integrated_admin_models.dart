// Modelos integrados para administración
// Archivo temporal para resolver errores de compilación

class IntegratedAdminModel {
  final String id;
  final String nombre;
  final DateTime createdAt;
  final DateTime updatedAt;

  IntegratedAdminModel({
    required this.id,
    required this.nombre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IntegratedAdminModel.fromJson(Map<String, dynamic> json) {
    return IntegratedAdminModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}