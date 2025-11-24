class EstadisticasMensajeria {

  factory EstadisticasMensajeria.fromJson(Map<String, dynamic> json) {
    return EstadisticasMensajeria(
      totalMensajes: _toInt(json['totalMensajes'] ?? json['total_messages']),
      mensajesNoLeidos: _toInt(json['mensajesNoLeidos'] ?? json['unread_messages']),
      totalConversaciones: _toInt(json['totalConversaciones'] ?? json['total_conversations']),
      data: json,
    );
  }
  const EstadisticasMensajeria({
    this.totalMensajes,
    this.mensajesNoLeidos,
    this.totalConversaciones,
    this.data,
  });
  final int? totalMensajes;
  final int? mensajesNoLeidos;
  final int? totalConversaciones;
  final Map<String, dynamic>? data;

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}