class Conversacion {

  factory Conversacion.fromJson(Map<String, dynamic> json) {
    return Conversacion(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      titulo: json['titulo'] as String?,
      ultimoMensaje: json['ultimoMensaje'] as String?,
      ultimoMensajeFecha: json['ultimoMensajeFecha'] != null
          ? DateTime.tryParse(json['ultimoMensajeFecha'].toString())
          : null,
    );
  }
  const Conversacion({
    required this.id,
    this.titulo,
    this.ultimoMensaje,
    this.ultimoMensajeFecha,
  });
  final String id;
  final String? titulo;
  final String? ultimoMensaje;
  final DateTime? ultimoMensajeFecha;
}