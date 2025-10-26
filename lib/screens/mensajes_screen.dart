import 'package:flutter/material.dart';
import '../models/mensaje.dart';
import '../services/mensaje_service.dart';
import '../services/logger_service.dart';

/// Pantalla de lista de conversaciones
class MensajesScreen extends StatefulWidget {
  const MensajesScreen({super.key});

  @override
  State<MensajesScreen> createState() => _MensajesScreenState();
}

class _MensajesScreenState extends State<MensajesScreen> {
  final _mensajeService = MensajeService();
  final _logger = LoggerService();
  
  List<Conversacion> _conversaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarConversaciones();
    _escucharMensajesNuevos();
  }

  Future<void> _cargarConversaciones() async {
    try {
      setState(() => _isLoading = true);
      
      final conversaciones = await _mensajeService.obtenerConversaciones();
      
      setState(() {
        _conversaciones = conversaciones;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      _logger.error('Error cargando conversaciones', error: e, stackTrace: stackTrace);
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando conversaciones: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _escucharMensajesNuevos() {
    _mensajeService.mensajesStream.listen((mensaje) {
      // Actualizar conversación con nuevo mensaje
      _cargarConversaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarConversaciones,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Crear nueva conversación
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear conversación - Por implementar')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conversaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No hay conversaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Inicia una nueva conversación',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarConversaciones,
      child: ListView.builder(
        itemCount: _conversaciones.length,
        itemBuilder: (context, index) {
          final conversacion = _conversaciones[index];
          return _buildConversacionTile(conversacion);
        },
      ),
    );
  }

  Widget _buildConversacionTile(Conversacion conversacion) {
    final ultimoMensaje = conversacion.ultimoMensaje ?? 'Sin mensajes';
    final fecha = conversacion.ultimoMensajeFecha;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          conversacion.titulo?.substring(0, 1).toUpperCase() ?? 'C',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        conversacion.titulo ?? 'Conversación',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        ultimoMensaje,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (fecha != null)
            Text(
              _formatearFecha(fecha),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          // TODO: Badge de mensajes no leídos
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversacion: conversacion),
          ),
        );
      },
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return '${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return '${diferencia.inDays}d';
    } else {
      return '${fecha.day}/${fecha.month}';
    }
  }
}

/// Pantalla de chat individual
class ChatScreen extends StatefulWidget {
  final Conversacion conversacion;

  const ChatScreen({super.key, required this.conversacion});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _mensajeService = MensajeService();
  final _logger = LoggerService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<Mensaje> _mensajes = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
    _unirseAConversacion();
    _escucharMensajesNuevos();
  }

  @override
  void dispose() {
    _mensajeService.salirDeConversacion(widget.conversacion.id);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarMensajes() async {
    try {
      setState(() => _isLoading = true);
      
      final mensajes = await _mensajeService.obtenerMensajes(
        conversacionId: widget.conversacion.id,
      );
      
      setState(() {
        _mensajes = mensajes.reversed.toList();
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (e, stackTrace) {
      _logger.error('Error cargando mensajes', error: e, stackTrace: stackTrace);
      setState(() => _isLoading = false);
    }
  }

  void _unirseAConversacion() {
    _mensajeService.unirseAConversacion(widget.conversacion.id);
  }

  void _escucharMensajesNuevos() {
    _mensajeService.mensajesStream.listen((mensaje) {
      if (mensaje.conversacionId == widget.conversacion.id) {
        setState(() {
          _mensajes.add(mensaje);
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _enviarMensaje() async {
    final contenido = _textController.text.trim();
    if (contenido.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _textController.clear();

    try {
      await _mensajeService.enviarMensaje(
        conversacionId: widget.conversacion.id,
        contenido: contenido,
      );
      
      _scrollToBottom();
    } catch (e, stackTrace) {
      _logger.error('Error enviando mensaje', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enviando mensaje: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversacion.titulo ?? 'Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _mensajes.length,
                    itemBuilder: (context, index) {
                      final mensaje = _mensajes[index];
                      return _buildMensajeBubble(mensaje);
                    },
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMensajeBubble(Mensaje mensaje) {
    // TODO: Determinar si es mensaje propio
    const esPropio = false; // mensaje.remitenteId == currentUserId
    
    return Align(
      alignment: esPropio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: esPropio ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!esPropio)
              Text(
                mensaje.remitenteNombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            Text(
              mensaje.contenido,
              style: const TextStyle(
                color: esPropio ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatearHora(mensaje.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: esPropio ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _enviarMensaje(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isSending ? null : _enviarMensaje,
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}

