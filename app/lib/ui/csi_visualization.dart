import 'dart:math' as math;
import 'package:flutter/material.dart';

class CsiVisualization extends StatelessWidget {
  final List<double> values;
  final bool presence;
  final bool motion;
  final double signalQuality;
  const CsiVisualization({super.key, required this.values, required this.presence, required this.motion, required this.signalQuality});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _CsiHeatmapPainter(values: values, presence: presence))),
          Positioned(left: 14, top: 14, child: _Badge(icon: motion ? Icons.directions_walk_rounded : Icons.person_outline_rounded, text: motion ? 'MOVIMENTO DETECTADO' : (presence ? 'PRESENÇA DETECTADA' : 'AMBIENTE LIVRE'), color: motion ? const Color(0xFFFFB300) : const Color(0xFF23E66F))),
          Positioned(right: 14, top: 14, child: _Badge(icon: Icons.wifi_rounded, text: 'CSI ${(signalQuality * 100).round()}%', color: const Color(0xFF20D9FF))),
          const Positioned(left: 14, bottom: 14, child: Text('MAPA DE INTENSIDADE DO SINAL', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2))),
          const Positioned(right: 14, bottom: 12, child: Row(children: [Text('FRACO', style: TextStyle(color: Colors.white54, fontSize: 8)), SizedBox(width: 5), SizedBox(width: 80, height: 7, child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue, Colors.cyan, Colors.green, Colors.yellow, Colors.red])))), SizedBox(width: 5), Text('FORTE', style: TextStyle(color: Colors.white54, fontSize: 8))])),
        ]),
      );
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Badge({required this.icon, required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: Colors.black.withOpacity(.72), borderRadius: BorderRadius.circular(9), border: Border.all(color: color.withOpacity(.55))), child: Row(children: [Icon(icon, color: color, size: 14), const SizedBox(width: 6), Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .7))]));
}

class _CsiHeatmapPainter extends CustomPainter {
  final List<double> values;
  final bool presence;
  const _CsiHeatmapPainter({required this.values, required this.presence});

  Color _thermal(double value) {
    final v = value.clamp(0, 1).toDouble();
    if (v < .25) return Color.lerp(const Color(0xFF071A73), const Color(0xFF00B8FF), v / .25)!;
    if (v < .5) return Color.lerp(const Color(0xFF00B8FF), const Color(0xFF17D96B), (v - .25) / .25)!;
    if (v < .75) return Color.lerp(const Color(0xFF17D96B), const Color(0xFFFFD31A), (v - .5) / .25)!;
    return Color.lerp(const Color(0xFFFFD31A), const Color(0xFFFF2415), (v - .75) / .25)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF020617));
    final grid = Paint()..color = const Color(0xFF20D9FF).withOpacity(.10)..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += size.width / 8) canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (var y = 0.0; y <= size.height; y += size.height / 6) canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    const cols = 8;
    const rows = 6;
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final data = values.length == 48 ? values : List<double>.filled(48, 0);
    for (var i = 0; i < data.length; i++) {
      final x = i % cols;
      final y = i ~/ cols;
      final value = data[i].clamp(0, 1).toDouble();
      final center = Offset((x + .5) * cellW, (y + .5) * cellH);
      final radius = math.max(cellW, cellH) * .95;
      final glow = Paint()..shader = RadialGradient(colors: [_thermal(value).withOpacity(.85), _thermal(value).withOpacity(.25), Colors.transparent], stops: const [0, .42, 1]).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, glow);
    }
    if (presence) {
      final scan = Paint()..color = const Color(0xFF20D9FF).withOpacity(.55)..strokeWidth = 1.4;
      final t = DateTime.now().millisecondsSinceEpoch / 1000;
      final y = (t % 2) / 2 * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scan);
    }
  }
  @override
  bool shouldRepaint(covariant _CsiHeatmapPainter oldDelegate) => true;
}
