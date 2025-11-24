import 'package:flutter/material.dart';

enum ChartType { bar, pie, line }

class ChartData {
  const ChartData({
    required this.label,
    required this.valor,
    this.color,
  });
  final String label;
  final double valor;
  final Color? color;
}

class ReporteChart extends StatelessWidget {
  const ReporteChart({
    super.key,
    required this.titulo,
    required this.datos,
    required this.tipo,
  });
  final String titulo;
  final List<ChartData> datos;
  final ChartType tipo;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    switch (tipo) {
      case ChartType.bar:
        final max = datos.map((d) => d.valor).fold<double>(0, (p, e) => e > p ? e : p);
        return Column(
          children: datos
              .map((d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(d.label),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: (d.color ?? Colors.blue).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: max > 0 ? (d.valor / max).clamp(0.0, 1.0) : 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: d.color ?? Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(d.valor.toStringAsFixed(0)),
                      ],
                    ),
                  ))
              .toList(),
        );
      case ChartType.pie:
        final total = datos.map((d) => d.valor).fold<double>(0, (p, e) => p + e);
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: datos.map((d) {
            final pct = total > 0 ? (d.valor / total * 100).toStringAsFixed(1) : '0.0';
            return Chip(
              backgroundColor: (d.color ?? Colors.blue).withValues(alpha: 0.15),
              label: Text('${d.label}: $pct%'),
            );
          }).toList(),
        );
      case ChartType.line:
        return Column(
          children: datos
              .map((d) => Row(
                    children: [
                      Expanded(child: Text(d.label)),
                      Text(d.valor.toStringAsFixed(0)),
                    ],
                  ))
              .toList(),
        );
    }
  }
}
