import 'package:flutter/material.dart';
import '../players/multimedia_player.dart';
import '../../../data/models/contenido_unificado.dart';

class ContenidoPlayerWidget extends StatelessWidget {

  const ContenidoPlayerWidget({
    super.key,
    required this.contenido,
    this.autoPlay = false,
    this.onCompleted,
    this.onPositionChanged,
  });
  final ContenidoUnificado contenido;
  final bool autoPlay;
  final Function()? onCompleted;
  final Function(Duration position)? onPositionChanged;

  @override
  Widget build(BuildContext context) {
    return MultimediaPlayer(
      contenido: contenido,
      onProgressUpdate: onPositionChanged,
      onCompleted: onCompleted,
      progresoService: null,
      autoPlay: autoPlay,
    );
  }
}
