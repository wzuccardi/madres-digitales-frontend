import 'package:flutter/material.dart';

class ReporteChart extends StatelessWidget {
  final String titulo;
  final List<ChartData> datos;
  final ChartType tipo;

  const ReporteChart({
    super.key,
    required this.titulo,
    required this.datos,
    this.tipo = ChartType.bar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChart(),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (datos.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    final maxValue = datos.map((d) => d.valor).reduce((a, b) => a > b ? a : b);

    switch (tipo) {
      case ChartType.bar:
        return _buildBarChart(maxValue);
      case ChartType.pie:
        return _buildPieChart();
      case ChartType.line:
        return _buildLineChart(maxValue);
    }
  }

  Widget _buildBarChart(double maxValue) {
    return SizedBox(
      height: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: datos.map((data) {
          final altura = (data.valor / maxValue) * 200;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 40,
                height: altura,
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 50,
                child: Text(
                  data.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    final total = datos.fold<double>(0, (sum, d) => sum + d.valor);
    double startAngle = 0;

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: PieChartPainter(
              datos: datos,
              total: total,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                total.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Total'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(double maxValue) {
    return SizedBox(
      height: 250,
      child: CustomPaint(
        size: const Size(double.infinity, 250),
        painter: LineChartPainter(
          datos: datos,
          maxValue: maxValue,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: datos.map((data) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${data.label}: ${data.valor.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class ChartData {
  final String label;
  final double valor;
  final Color color;

  ChartData({
    required this.label,
    required this.valor,
    required this.color,
  });
}

enum ChartType { bar, pie, line }

class PieChartPainter extends CustomPainter {
  final List<ChartData> datos;
  final double total;

  PieChartPainter({
    required this.datos,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = -3.14159 / 2;

    for (final data in datos) {
      final sweepAngle = (data.valor / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = data.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) => false;
}

class LineChartPainter extends CustomPainter {
  final List<ChartData> datos;
  final double maxValue;

  LineChartPainter({
    required this.datos,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    if (datos.isEmpty) return;

    final width = size.width / (datos.length - 1).clamp(1, double.infinity);
    final height = size.height;

    Path path = Path();
    for (int i = 0; i < datos.length; i++) {
      final x = i * width;
      final y = height - (datos[i].valor / maxValue) * height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) => false;
}

