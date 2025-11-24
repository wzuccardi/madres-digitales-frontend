class Geolocalizacion {

  Geolocalizacion({
    required this.id,
    required this.latitud,
    required this.longitud,
    required this.fechaRegistro,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Geolocalizacion.fromJson(Map<String, dynamic> json) {
    return Geolocalizacion(
      id: json['id'] ?? '',
      latitud: json['latitud']?.toDouble() ?? 0.0,
      longitud: json['longitud']?.toDouble() ?? 0.0,
      fechaRegistro: json['fechaRegistro'] != null 
          ? DateTime.parse(json['fechaRegistro']) 
          : DateTime.now(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  final String id;
  final double latitud;
  final double longitud;
  final DateTime fechaRegistro;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitud': latitud,
      'longitud': longitud,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Geolocalizacion copyWith({
    String? id,
    double? latitud,
    double? longitud,
    DateTime? fechaRegistro,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Geolocalizacion(
      id: id ?? this.id,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Geolocalizacion &&
        other.id == id &&
        other.latitud == latitud &&
        other.longitud == longitud;
  }

  @override
  int get hashCode {
    return id.hashCode ^ latitud.hashCode ^ longitud.hashCode;
  }

  @override
  String toString() {
    return 'Geolocalizacion(id: $id, lat: $latitud, lng: $longitud)';
  }
}
