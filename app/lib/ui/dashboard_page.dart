import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/occupancy_state.dart';

const _bg = Color(0xFF05080D);
const _panel = Color(0xFF0A1019);
const _line = Color(0xFF172332);
const _green = Color(0xFF22E36F);
const _cyan = Color(0xFF20D9FF);
const _red = Color(0xFFFF4655);
const _amber = Color(0xFFFFB51B);

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OccupancyState>();
    final s = state.snapshot;
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(state: state),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
                child: isWide
                    ? _WideDashboard(state: state, snapshot: s)
                    : _MobileDashboard(state: state, snapshot: s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final OccupancyState state;
  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF070B11),
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _green.withOpacity(.55)),
              color: _green.withOpacity(.08),
            ),
            child: const Icon(Icons.radar_rounded, color: _green),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MARQUESLAB', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                Text('PEOPLE COUNTER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3, color: Colors.white54)),
              ],
            ),
          ),
          _Status(label: 'SENSOR 01', active: state.backendOnline || !state.demoMode),
          const SizedBox(width: 18),
          if (MediaQuery.sizeOf(context).width >= 600)
            const _HeaderSignal(),
          IconButton(
            tooltip: 'Fonte de dados',
            onPressed: () => state.demoMode ? state.startBackendStream() : state.startDemoStream(),
            icon: Icon(state.demoMode ? Icons.science_outlined : Icons.cloud_outlined, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final String label;
  final bool active;
  const _Status({required this.label, required this.active});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(color: active ? _green : Colors.white24, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : Colors.white38)),
        ],
      );
}

class _HeaderSignal extends StatelessWidget {
  const _HeaderSignal();
  @override
  Widget build(BuildContext context) => const Row(
        children: [
          Icon(Icons.wifi_rounded, color: _green, size: 27),
          SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Wi-Fi CSI', style: TextStyle(fontWeight: FontWeight.w800)), Text('ATIVO', style: TextStyle(fontSize: 9, color: _green, letterSpacing: 1.5))]),
        ],
      );
}

class _WideDashboard extends StatelessWidget {
  final OccupancyState state;
  final dynamic snapshot;
  const _WideDashboard({required this.state, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 5, child: Column(children: [
            _SectionTitle(title: 'CÂMERA CSI — SENSOR 01', live: !state.demoMode),
            const SizedBox(height: 8),
            const _ThermalPanel(),
            const SizedBox(height: 10),
            const _HeatMapPanel(),
          ])),
          const SizedBox(width: 10),
          Expanded(flex: 5, child: Column(children: [
            _OccupancyCard(people: snapshot.people, confidence: snapshot.confidence),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _FlowCard(title: 'ENTRANDO', value: '+${snapshot.enteringPerMinute}', icon: Icons.arrow_forward_rounded, color: _green)),
              const SizedBox(width: 8),
              Expanded(child: _FlowCard(title: 'SAINDO', value: '-${snapshot.leavingPerMinute}', icon: Icons.arrow_back_rounded, color: _red)),
              const SizedBox(width: 8),
              const Expanded(child: _FlowCard(title: 'FLUXO ATUAL', value: '+2', icon: Icons.swap_vert_rounded, color: _cyan)),
            ]),
            const SizedBox(height: 10),
            const _TrendPanel(),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _ZonesPanel(zones: snapshot.zones)),
              const SizedBox(width: 8),
              Expanded(child: _SensorsPanel(count: snapshot.activeSensors)),
            ]),
          ])),
        ]),
        const SizedBox(height: 10),
        const _FooterFeatures(),
      ],
    );
  }
}

class _MobileDashboard extends StatelessWidget {
  final OccupancyState state;
  final dynamic snapshot;
  const _MobileDashboard({required this.state, required this.snapshot});

  @override
  Widget build(BuildContext context) => Column(children: [
        _SectionTitle(title: 'CÂMERA CSI — SENSOR 01', live: !state.demoMode),
        const SizedBox(height: 8),
        const _ThermalPanel(height: 260),
        const SizedBox(height: 10),
        _OccupancyCard(people: snapshot.people, confidence: snapshot.confidence),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _FlowCard(title: 'ENTRANDO', value: '+${snapshot.enteringPerMinute}', icon: Icons.arrow_forward_rounded, color: _green)),
          const SizedBox(width: 7),
          Expanded(child: _FlowCard(title: 'SAINDO', value: '-${snapshot.leavingPerMinute}', icon: Icons.arrow_back_rounded, color: _red)),
        ]),
        const SizedBox(height: 8),
        _ZonesPanel(zones: snapshot.zones),
        const SizedBox(height: 8),
        _SensorsPanel(count: snapshot.activeSensors),
        const SizedBox(height: 8),
        const _HeatMapPanel(),
      ]);
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool live;
  const _SectionTitle({required this.title, required this.live});
  @override
  Widget build(BuildContext context) => Row(children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        const Spacer(),
        if (live) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: _green.withOpacity(.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _green.withOpacity(.7))), child: const Row(children: [Icon(Icons.circle, size: 7, color: _green), SizedBox(width: 6), Text('AO VIVO', style: TextStyle(color: _green, fontWeight: FontWeight.w800, fontSize: 10))])) else Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: _amber.withOpacity(.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: _amber.withOpacity(.4))), child: const Text('AGUARDANDO CSI', style: TextStyle(color: _amber, fontWeight: FontWeight.w800, fontSize: 10))),
      ]);
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _Panel({required this.child, this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: _line)),
        padding: padding,
        child: child,
      );
}

class _ThermalPanel extends StatelessWidget {
  final double height;
  const _ThermalPanel({this.height = 300});
  @override
  Widget build(BuildContext context) => _Panel(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _ThermalPainter())),
              Positioned(top: 14, right: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), color: Colors.black54, child: const Text('CSI / SPECTRUM', style: TextStyle(fontSize: 9, color: Colors.white70, letterSpacing: 1.3)))),
              const Positioned(left: 14, bottom: 14, child: _SignalQuality()),
              Positioned(right: 15, bottom: 54, child: Column(children: [const Text('FORTE', style: TextStyle(fontSize: 8, color: Colors.white70)), Container(width: 10, height: 85, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.blue, Colors.cyan, Colors.green, Colors.yellow, Colors.red]))), const Text('FRACO', style: TextStyle(fontSize: 8, color: Colors.white70))])),
            ]),
          ),
        ),
      );
}

class _SignalQuality extends StatelessWidget {
  const _SignalQuality();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: Colors.black.withOpacity(.7), borderRadius: BorderRadius.circular(10), border: Border.all(color: _line)), child: Row(children: [const Icon(Icons.circle, color: _green, size: 9), const SizedBox(width: 7), const Text('QUALIDADE DO SINAL  ', style: TextStyle(fontSize: 10, color: Colors.white70)), ...List.generate(7, (i) => Container(width: 7, height: 13, margin: const EdgeInsets.only(left: 2), color: i < 6 ? _green : Colors.white12)), const SizedBox(width: 7), const Text('92%', style: TextStyle(fontWeight: FontWeight.w900))]));
}

class _ThermalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF03071B), Color(0xFF061E55), Color(0xFF071127)]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    final grid = Paint()..color = Colors.cyan.withOpacity(.08)..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 35) canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (var y = 0.0; y < size.height; y += 35) canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    final people = [
      Offset(size.width * .23, size.height * .46),
      Offset(size.width * .57, size.height * .50),
      Offset(size.width * .69, size.height * .51),
      Offset(size.width * .80, size.height * .53),
      Offset(size.width * .89, size.height * .55),
    ];
    for (var i = 0; i < people.length; i++) {
      final p = people[i];
      final h = size.height * (i == 0 ? .57 : .38);
      final glow = Paint()..shader = RadialGradient(colors: [Colors.red.withOpacity(.95), Colors.orange.withOpacity(.85), Colors.yellow.withOpacity(.55), Colors.green.withOpacity(.25), Colors.transparent]).createShader(Rect.fromCircle(center: p.translate(0, -h * .25), radius: h * .65));
      canvas.drawOval(Rect.fromCenter(center: p.translate(0, -h * .20), width: h * .55, height: h * 1.05), glow);
      final head = Paint()..color = i == 0 ? Colors.red : Colors.orange;
      canvas.drawCircle(p.translate(0, -h * .62), h * .10, head);
      final body = Paint()..color = Colors.green.withOpacity(.72);
      canvas.drawOval(Rect.fromCenter(center: p.translate(0, -h * .32), width: h * .38, height: h * .52), body);
    }
    final scan = Paint()..color = _cyan.withOpacity(.5)..strokeWidth = 1.5;
    final y = (DateTime.now().millisecond / 1000) * size.height;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), scan);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _OccupancyCard extends StatelessWidget {
  final int people;
  final double confidence;
  const _OccupancyCard({required this.people, required this.confidence});
  @override
  Widget build(BuildContext context) => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PESSOAS PRESENTES', style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const Text('ESTIMATIVA ATUAL', style: TextStyle(fontSize: 10, color: Colors.white38)),
        const SizedBox(height: 2),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('$people', style: const TextStyle(fontSize: 62, height: 1, fontWeight: FontWeight.w900)), const SizedBox(width: 12), const Icon(Icons.person_rounded, color: _green, size: 42)]),
        const SizedBox(height: 8),
        Row(children: [const Text('CONFIANÇA: ', style: TextStyle(color: Colors.white60)), Text('${(confidence * 100).round()}%', style: const TextStyle(color: _green, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: confidence, minHeight: 6, backgroundColor: Colors.white10, color: _green)),
      ]));
}

class _FlowCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _FlowCard({required this.title, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => _Panel(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 20), const SizedBox(height: 8), Text(title, style: const TextStyle(fontSize: 9, color: Colors.white54, letterSpacing: .8)), const SizedBox(height: 3), Text(value, style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.w900)), const Text('/min', style: TextStyle(color: Colors.white38, fontSize: 10))]));
}

class _TrendPanel extends StatelessWidget {
  const _TrendPanel();
  @override
  Widget build(BuildContext context) => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Text('CONTAGEM EM TEMPO REAL', style: TextStyle(fontWeight: FontWeight.w900)), Spacer(), Text('10 MINUTOS  ▾', style: TextStyle(fontSize: 9, color: Colors.white54))]),
        const SizedBox(height: 10),
        SizedBox(height: 120, child: CustomPaint(painter: _ChartPainter(), child: const SizedBox.expand())),
      ]));
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = Colors.white.withOpacity(.06)..strokeWidth = 1;
    for (var i = 0; i < 5; i++) canvas.drawLine(Offset(0, i * size.height / 4), Offset(size.width, i * size.height / 4), grid);
    for (var i = 0; i < 8; i++) canvas.drawLine(Offset(i * size.width / 7, 0), Offset(i * size.width / 7, size.height), grid);
    final line = Paint()..color = _green..strokeWidth = 2.2..style = PaintingStyle.stroke;
    final fill = Paint()..color = _green.withOpacity(.10)..style = PaintingStyle.fill;
    final path = Path()..moveTo(0, size.height * .70);
    for (var i = 0; i <= 30; i++) {
      final x = i / 30 * size.width;
      final wave = math.sin(i * .55) * 3 + (i > 20 ? (i - 20) * 1.8 : 0);
      final y = size.height * .72 - wave;
      path.lineTo(x, y.clamp(4, size.height - 4));
    }
    final area = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(area, fill);
    canvas.drawPath(path, line);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeatMapPanel extends StatelessWidget {
  const _HeatMapPanel();
  @override
  Widget build(BuildContext context) => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MAPA DE CALOR (AMBIENTE)', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        SizedBox(height: 190, child: CustomPaint(painter: _HeatMapPainter(), child: const SizedBox.expand())),
      ]));
}

class _HeatMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8));
    canvas.drawRRect(rect, Paint()..color = const Color(0xFF06152D));
    final plan = Paint()..color = _cyan.withOpacity(.16)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromLTWH(size.width * .08, size.height * .12, size.width * .84, size.height * .72), plan);
    for (final x in [0.22, .48, .70]) canvas.drawLine(Offset(size.width * x, size.height * .12), Offset(size.width * x, size.height * .84), plan);
    for (final y in [.42, .66]) canvas.drawLine(Offset(size.width * .08, size.height * y), Offset(size.width * .92, size.height * y), plan);
    final spots = [Offset(.25, .34), Offset(.48, .58), Offset(.60, .52), Offset(.76, .42), Offset(.82, .68)];
    for (final spot in spots) {
      final center = Offset(size.width * spot.dx, size.height * spot.dy);
      canvas.drawCircle(center, 38, Paint()..shader = RadialGradient(colors: [Colors.red.withOpacity(.9), Colors.orange.withOpacity(.65), Colors.green.withOpacity(.35), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: 38)));
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ZonesPanel extends StatelessWidget {
  final Map<String, int> zones;
  const _ZonesPanel({required this.zones});
  @override
  Widget build(BuildContext context) => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ZONAS', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        _ZoneRow('ENTRADA', zones['Entrada'] ?? 0, _green),
        _ZoneRow('PISTA', zones['Pista'] ?? 0, _cyan),
        _ZoneRow('CAMAROTE', zones['Camarote'] ?? 0, _amber),
        const Divider(color: _line),
        Row(children: [const Text('TOTAL', style: TextStyle(color: _green, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${zones.values.fold<int>(0, (a, b) => a + b)}', style: const TextStyle(color: _green, fontSize: 24, fontWeight: FontWeight.w900))]),
      ]));
}

class _ZoneRow extends StatelessWidget {
  final String name;
  final int value;
  final Color color;
  const _ZoneRow(this.name, this.value, this.color);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 8), Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))), Text('$value', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), const SizedBox(width: 7), const Icon(Icons.person_outline, color: _green, size: 17)]));
}

class _SensorsPanel extends StatelessWidget {
  final int count;
  const _SensorsPanel({required this.count});
  @override
  Widget build(BuildContext context) => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('SENSORES', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        _SensorRow('SENSOR 01', 'Principal', _green, '93%'),
        _SensorRow('SENSOR 02', 'Pista', _green, '86%'),
        _SensorRow('SENSOR 03', 'Camarote', _amber, '78%'),
        const SizedBox(height: 5),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(border: Border.all(color: _line), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('+ ADICIONAR SENSOR', style: TextStyle(color: _green, fontWeight: FontWeight.w800, fontSize: 11))),
      ]));
}

class _SensorRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final String quality;
  const _SensorRow(this.title, this.subtitle, this.color, this.quality);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 9))])), const Icon(Icons.signal_cellular_alt_rounded, color: _green, size: 18), const SizedBox(width: 5), Text(quality, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11))]));
}

class _FooterFeatures extends StatelessWidget {
  const _FooterFeatures();
  @override
  Widget build(BuildContext context) => _Panel(child: Wrap(alignment: WrapAlignment.spaceAround, runSpacing: 14, children: const [
        _Feature(icon: Icons.radar_rounded, title: 'DETECÇÃO CSI', text: 'Movimento sem câmera'),
        _Feature(icon: Icons.bolt_rounded, title: 'TEMPO REAL', text: 'Dados instantâneos'),
        _Feature(icon: Icons.settings_rounded, title: 'FÁCIL INSTALAÇÃO', text: 'Sensores distribuídos'),
        _Feature(icon: Icons.cloud_rounded, title: 'API', text: 'Integrações'),
        _Feature(icon: Icons.bar_chart_rounded, title: 'DADOS', text: 'Relatórios inteligentes'),
      ]));
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _Feature({required this.icon, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => SizedBox(width: 145, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: _green, size: 24), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _green, fontWeight: FontWeight.w900, fontSize: 10)), const SizedBox(height: 2), Text(text, style: const TextStyle(color: Colors.white54, fontSize: 9))]))]));
}
