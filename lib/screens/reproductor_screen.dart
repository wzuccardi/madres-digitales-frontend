import 'package:flutter/material.dart';
import '../models/contenido_unificado.dart';

class ReproductorScreen extends StatefulWidget {
  final ContenidoUnificado contenido;

  const ReproductorScreen({
    super.key,
    required this.contenido,
  });

  @override
  State<ReproductorScreen> createState() => _ReproductorScreenState();
}

class _ReproductorScreenState extends State<ReproductorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contenido.titulo),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.contenido.urlImagen != null) // Corrección: usar urlImagen
              Image.network(
                widget.contenido.urlImagen!, // Corrección: usar urlImagen
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  );
                },
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.play_circle, size: 50),
              ),
            const SizedBox(height: 20),
            Text(
              widget.contenido.titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.contenido.descripcion ?? '', // Corrección: descripcion es nullable
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    // Implementar funcionalidad de anterior
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    // Implementar funcionalidad de reproducción
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    // Implementar funcionalidad de siguiente
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}