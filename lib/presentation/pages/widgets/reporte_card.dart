import 'package:flutter/material.dart';

class ReporteCard extends StatelessWidget {
  const ReporteCard({
    super.key,
    required this.titulo,
    this.descripcion,
    this.icono,
    this.color,
    this.onTap,
    this.datos,
  });
  final String titulo;
  final String? descripcion;
  final IconData? icono;
  final Color? color;
  final VoidCallback? onTap;
  final Map<String, num>? datos;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icono != null)
                    Icon(icono, color: c, size: 28),
                  if (icono != null) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (descripcion != null) ...[
                const SizedBox(height: 8),
                Text(
                  descripcion!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
              if (datos != null && datos!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Column(
                  children: datos!.entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key),
                                Text(
                                  e.value.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}