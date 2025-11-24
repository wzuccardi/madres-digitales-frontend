import '../domain/control_dto.dart';

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  if (s.isEmpty) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

ControlDto mapJsonToDto(Map<String, dynamic> json) {
  return ControlDto(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    gestanteId: (json['gestante_id'] ?? json['gestanteId'])?.toString(),
    fechaControl: _parseDate(json['fecha_control'] ?? json['fecha']),
    semanasGestacion: _parseInt(json['semanas_gestacion'] ?? json['semanasGestacion']),
    peso: _parseDouble(json['peso']),
    presionSistolica: _parseInt(json['presion_sistolica'] ?? json['presionSistolica']),
    presionDiastolica: _parseInt(json['presion_diastolica'] ?? json['presionDiastolica']),
    alturaUterina: _parseDouble(json['altura_uterina'] ?? json['alturaUterina']),
    frecuenciaCardiaca: _parseInt(json['frecuencia_cardiaca'] ?? json['frecuenciaCardiaca']),
    temperatura: _parseDouble(json['temperatura']),
    observaciones: (json['observaciones'] ?? json['descripcion'])?.toString(),
    recomendaciones: json['recomendaciones']?.toString(),
    proximoControl: _parseDate(json['proximo_control'] ?? json['fechaProgramada']),
    gestanteNombre: (json['gestante_nombre'] ?? json['gestanteNombre'])?.toString(),
    gestante: json['gestante'] is Map<String, dynamic> ? json['gestante'] as Map<String, dynamic> : null,
  );
}