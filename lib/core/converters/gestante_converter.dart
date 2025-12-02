import '../../domain/entities/gestante.dart';

abstract class GestanteConverter {
  static Gestante apiToGestante(Map<String, dynamic> api) => gestanteFromApi(api);
  static Map<String, dynamic> gestanteToApi(Gestante g) => gestanteToApiImpl(g);
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  final s = v.toString();
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}


Map<String, dynamic> _normalizeApiGestante(Map<String, dynamic> api) {
  final m = Map<String, dynamic>.from(api);
  final fn = _parseDate(m['fecha_nacimiento'] ?? m['fechaNacimiento']);
  final fpp = _parseDate(m['fecha_probable_parto'] ?? m['fechaProbableParto'] ?? m['fpp']);
  final fuc = _parseDate(m['fecha_ultimo_control']);
  final fum = _parseDate(m['fecha_ultima_mestruacion'] ?? m['fechaUltimaMestruacion']);
  final ca = _parseDate(m['created_at'] ?? m['createdAt']) ?? DateTime.now();
  final ua = _parseDate(m['updated_at'] ?? m['updatedAt']) ?? DateTime.now();
  
  // Handle coordinates from API (latitud/longitud) to Flutter format (coordenadas)
  String? coordenadas;
  if (m['latitud'] != null && m['longitud'] != null) {
    coordenadas = '${m['latitud']},${m['longitud']}';
  } else {
    coordenadas = m['coordenadas'];
  }
  
  // Map backend tipo_documento enum values to frontend format
  String? tipoDocumentoFrontend;
  switch (m['tipo_documento'] ?? m['tipoDocumento']) {
    case 'cedula':
      tipoDocumentoFrontend = 'CC';
      break;
    case 'tarjeta_identidad':
      tipoDocumentoFrontend = 'TI';
      break;
    case 'pasaporte':
      tipoDocumentoFrontend = 'PA';
      break;
    case 'registro_civil':
      tipoDocumentoFrontend = 'RC';
      break;
    default:
      tipoDocumentoFrontend = m['tipo_documento'] ?? m['tipoDocumento'];
  }
  
  return {
    'id': m['id']?.toString(),
    'nombre': m['nombre'] ?? m['first_name'] ?? m['nombres'],
    'apellido': m['apellido'] ?? m['last_name'] ?? m['apellidos'],
    'documento': m['documento'] ?? m['numero_documento'] ?? m['numeroDocumento'],
    'telefono': m['telefono'] ?? m['phone'],
    'direccion': m['direccion'] ?? m['address'],
    'email': m['email'],
    'fechaNacimiento': fn?.toIso8601String(),
    'eps': m['eps'],
    'regimen': m['regimen_salud'] ?? m['healthRegime'] ?? 'subsidiado',
    'activa': m['activa'] ?? m['active'] ?? true,
    'riesgoAlto': m['riesgo_alto'] ?? m['esAltoRiesgo'] ?? false,
    'fechaProbableParto': fpp?.toIso8601String(),
    'madrinaId': m['madrina_id'],
    'ipsId': m['ips_id'] ?? m['ips_asignada_id'],
    'medicoId': m['medico_tratante_id'],
    'fechaUltimoControl': fuc?.toIso8601String(),
    'semanasGestacion': m['semanas_gestacion'],
    'estado': m['estado'],
    'municipio': m['municipio'],
    'municipio_id': m['municipio_id']?.toString(),
    'createdAt': ca.toIso8601String(),
    'updatedAt': ua.toIso8601String(),
    'tipoDocumento': tipoDocumentoFrontend,
    'fechaUltimaMestruacion': fum?.toIso8601String(),
    'barrio': m['barrio'],
    'coordenadas': coordenadas,
    'numeroEmbarazo': m['numero_embarazo'] ?? 1,
  }..removeWhere((_, v) => v == null);
}

Gestante gestanteFromApi(Map<String, dynamic> api) {
  final normalized = _normalizeApiGestante(api);
  return Gestante.fromJson(normalized);
}

Map<String, dynamic> gestanteToApiImpl(Gestante g) {
  // Parse coordinates if they exist (format: "lat,long")
  double? latitud;
  double? longitud;
  if (g.coordenadas != null && g.coordenadas!.contains(',')) {
    final coords = g.coordenadas!.split(',');
    if (coords.length == 2) {
      latitud = double.tryParse(coords[0].trim());
      longitud = double.tryParse(coords[1].trim());
    }
  }

  // Map frontend tipo_documento values to backend enum values
  String? tipoDocumentoBackend;
  switch (g.tipoDocumento) {
    case 'CC':
      tipoDocumentoBackend = 'cedula';
      break;
    case 'TI':
      tipoDocumentoBackend = 'tarjeta_identidad';
      break;
    case 'CE':
      tipoDocumentoBackend = 'cedula'; // Map to cedula as there's no extranjeria in backend
      break;
    case 'PA':
      tipoDocumentoBackend = 'pasaporte';
      break;
    case 'RC':
      tipoDocumentoBackend = 'registro_civil';
      break;
    default:
      tipoDocumentoBackend = g.tipoDocumento;
  }

  return {
    'id': g.id,
    'nombre': g.nombre,
    'apellido': g.apellido,
    'documento': g.documento,
    'telefono': g.telefono,
    'direccion': g.direccion,
    'email': g.email,
    'fecha_nacimiento': g.fechaNacimiento?.toIso8601String(),
    'eps': g.eps,
    'regimen_salud': g.regimen,
    'activa': g.activa,
    'riesgo_alto': g.riesgoAlto,
    'fecha_probable_parto': g.fechaProbableParto?.toIso8601String(),
    'madrina_id': g.madrinaId,
    'ips_id': g.ipsId,
    'medico_tratante_id': g.medicoId,
    'fecha_ultimo_control': g.fechaUltimoControl?.toIso8601String(),
    'semanas_gestacion': g.semanasGestacion,
    'estado': g.estado,
    'municipio_id': g.municipioId,
    'created_at': g.createdAt.toIso8601String(),
    'updated_at': g.updatedAt.toIso8601String(),
    'tipo_documento': tipoDocumentoBackend,
    'fecha_ultima_menstruacion': g.fechaUltimaMestruacion?.toIso8601String(),
    'barrio': g.barrio,
    'latitud': latitud,
    'longitud': longitud,
    'numero_embarazo': g.numeroEmbarazo ?? 1,
  }..removeWhere((_, v) => v == null);
}
