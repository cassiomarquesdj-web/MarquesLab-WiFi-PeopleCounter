import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/occupancy_state.dart';
import 'csi_visualization.dart';

const bg = Color(0xFF05080D);
const panel = Color(0xFF0A1019);
const line = Color(0xFF172332);
const green = Color(0xFF22E36F);
const cyan = Color(0xFF20D9FF);
const red = Color(0xFFFF4655);
const amber = Color(0xFFFFB51B);

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OccupancyState>();
    final s = state.snapshot;
    final wide = MediaQuery.sizeOf(context).width >= 720;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          _TopBar(state: state),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: wide ? _Wide(state: state) : _Mobile(state: state))),
        ]),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final OccupancyState state;
  const _TopBar({required this.state});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        decoration: const BoxDecoration(color: Color(0xFF070B11), border: Border(bottom: BorderSide(color: line))),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: green.withOpacity(.08), border: Border.all(color: green.withOpacity(.55))), child: const Icon(Icons.radar_rounded, color: green)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MARQUESLAB', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)), Text('PEOPLE COUNTER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3, color: Colors.white54))])),
          _Status(label: state.backendOnline ? 'SENSOR ONLINE' : 'AGUARDANDO SENSOR', active: state.backendOnline),
          const SizedBox(width: 14),
          if (MediaQuery.sizeOf(context).width >= 600) const _WifiStatus(),
          IconButton(onPressed: state.toggleSecurity, tooltip: 'Modo segurança', icon: Icon(state.securityArmed ? Icons.shield_rounded : Icons.shield_outlined, color: state.securityArmed ? green : Colors.white60)),
        ]),
      );
}

class _Status extends StatelessWidget {
  final String label;
  final bool active;
  const _Status({required this.label, required this.active});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: active ? green : amber, shape: BoxShape.circle)), const SizedBox(width: 7), Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: active ? Colors.white : amber))]);
}

class _WifiStatus extends StatelessWidget {
  const _WifiStatus();
  @override
  Widget build(BuildContext context) => const Row(children: [Icon(Icons.wifi_rounded, color: green, size: 26), SizedBox(width: 7), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Wi-Fi CSI', style: TextStyle(fontWeight: FontWeight.w800)), Text('SENSING', style: TextStyle(color: green, fontSize: 9, letterSpacing: 1.4))])]);
}

class _Wide extends StatelessWidget {
  final OccupancyState state;
  const _Wide({required this.state});
  @override
  Widget build(BuildContext context) {
    final s = state.snapshot;
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 5, child: Column(children: [
          _TitleRow(title: 'VISUALIZAÇÃO CSI — SENSOR 01', live: state.backendOnline),
          const SizedBox(height: 8),
          SizedBox(height: 370, child: CsiVisualization(values: s.heatmap, presence: s.presenceDetected, motion: s.motionDetected, signalQuality: s.signalQuality)),
          const SizedBox(height: 10),
          _SecurityCard(state: state),
        ])),
        const SizedBox(width: 10),
        Expanded(flex: 5, child: Column(children: [
          _Occupancy(s: s),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _Metric('ENTRANDO', '+${s.enteringPerMinute}', green)), const SizedBox(width: 8), Expanded(child: _Metric('SAINDO', '-${s.leavingPerMinute}', red)), const SizedBox(width: 8), Expanded(child: _Metric('FLUXO', '${s.enteringPerMinute - s.leavingPerMinute >= 0 ? '+' : ''}${s.enteringPerMinute - s.leavingPerMinute}', cyan))]),
          const SizedBox(height: 10),
          _ZonePanel(zones: s.zones),
          const SizedBox(height: 10),
          _SensorPanel(s: s),
        ])),
      ]),
      const SizedBox(height: 10),
      _InfoBar(backendOnline: state.backendOnline),
    ]);
  }
}

class _Mobile extends StatelessWidget {
  final OccupancyState state;
  const _Mobile({required this.state});
  @override
  Widget build(BuildContext context) {
    final s = state.snapshot;
    return Column(children: [
      _TitleRow(title: 'VISUALIZAÇÃO CSI — SENSOR 01', live: state.backendOnline),
      const SizedBox(height: 8),
      SizedBox(height: 300, child: CsiVisualization(values: s.heatmap, presence: s.presenceDetected, motion: s.motionDetected, signalQuality: s.signalQuality)),
      const SizedBox(height: 10),
      _Occupancy(s: s),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: _Metric('ENTRANDO', '+${s.enteringPerMinute}', green)), const SizedBox(width: 7), Expanded(child: _Metric('SAINDO', '-${s.leavingPerMinute}', red))]),
      const SizedBox(height: 8),
      _ZonePanel(zones: s.zones),
      const SizedBox(height: 8),
      _SensorPanel(s: s),
      const SizedBox(height: 8),
      _SecurityCard(state: state),
    ]);
  }
}

class _TitleRow extends StatelessWidget {
  final String title;
  final bool live;
  const _TitleRow({required this.title, required this.live});
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900))), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: (live ? green : amber).withOpacity(.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: (live ? green : amber).withOpacity(.5))), child: Row(children: [Icon(Icons.circle, size: 7, color: live ? green : amber), const SizedBox(width: 6), Text(live ? 'AO VIVO' : 'AGUARDANDO CSI', style: TextStyle(color: live ? green : amber, fontSize: 9, fontWeight: FontWeight.w900))]))]);
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: line)), child: child);
}

class _Occupancy extends StatelessWidget {
  final dynamic s;
  const _Occupancy({required this.s});
  @override
  Widget build(BuildContext context) => _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('PESSOAS PRESENTES', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)), const Text('ESTIMATIVA POR WI-FI CSI', style: TextStyle(color: Colors.white38, fontSize: 9)), Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${s.people}', style: const TextStyle(fontSize: 64, height: 1, fontWeight: FontWeight.w900)), const SizedBox(width: 12), Icon(s.presenceDetected ? Icons.person_rounded : Icons.person_off_rounded, color: s.presenceDetected ? green : Colors.white24, size: 42)]), const SizedBox(height: 8), Row(children: [const Text('CONFIANÇA: ', style: TextStyle(color: Colors.white60)), Text('${(s.confidence * 100).round()}%', style: const TextStyle(color: green, fontWeight: FontWeight.w900)), const Spacer(), Text(s.motionDetected ? 'MOVIMENTO' : 'ESTÁTICO', style: TextStyle(color: s.motionDetected ? amber : Colors.white54, fontWeight: FontWeight.w800, fontSize: 10))]), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: s.confidence, minHeight: 6, backgroundColor: Colors.white10, color: green))]));
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _Metric(this.title, this.value, this.color);
  @override
  Widget build(BuildContext context) => _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .8)), const SizedBox(height: 4), Text(value, style: TextStyle(color: color, fontSize: 25, fontWeight: FontWeight.w900)), const Text('/min', style: TextStyle(color: Colors.white38, fontSize: 9))]));
}

class _ZonePanel extends StatelessWidget {
  final Map<String, int> zones;
  const _ZonePanel({required this.zones});
  @override
  Widget build(BuildContext context) => _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('OCUPAÇÃO / ZONAS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 12), ...zones.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 11), child: Row(children: [Container(width: 8, height: 8, decoration: const BoxDecoration(color: green, shape: BoxShape.circle)), const SizedBox(width: 8), Expanded(child: Text(e.key)), Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(width: 10), SizedBox(width: 90, child: LinearProgressIndicator(value: (e.value / 20).clamp(0, 1), color: green, backgroundColor: Colors.white10))])))]));
}

class _SensorPanel extends StatelessWidget {
  final dynamic s;
  const _SensorPanel({required this.s});
  @override
  Widget build(BuildContext context) => _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('SENSORES CSI', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 12), Row(children: [const Icon(Icons.sensors_rounded, color: green), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('SENSOR 01', style: TextStyle(fontWeight: FontWeight.w800)), Text('Presença / movimento', style: TextStyle(color: Colors.white38, fontSize: 10))])), Text('${(s.signalQuality * 100).round()}%', style: const TextStyle(color: green, fontWeight: FontWeight.w900))]), const SizedBox(height: 10), Text('${s.activeSensors} sensor(es) ativo(s)', style: const TextStyle(color: Colors.white54, fontSize: 10))]));
}

class _SecurityCard extends StatelessWidget {
  final OccupancyState state;
  const _SecurityCard({required this.state});
  @override
  Widget build(BuildContext context) {
    final alert = state.securityArmed && state.snapshot.motionDetected;
    final color = alert ? red : (state.securityArmed ? green : Colors.white54);
    return _Card(child: Row(children: [Icon(state.securityArmed ? Icons.shield_rounded : Icons.shield_outlined, color: color, size: 30), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(state.securityArmed ? (alert ? 'ALERTA: MOVIMENTO' : 'PROTEÇÃO ATIVA') : 'MODO SEGURANÇA DESARMADO', style: TextStyle(color: color, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text('Detecção sem câmera usando alterações do canal Wi-Fi.', style: const TextStyle(color: Colors.white38, fontSize: 10))])), Switch(value: state.securityArmed, onChanged: (_) => state.toggleSecurity(), activeColor: green)]));
  }
}

class _InfoBar extends StatelessWidget {
  final bool backendOnline;
  const _InfoBar({required this.backendOnline});
  @override
  Widget build(BuildContext context) => _Card(child: Row(children: [Icon(backendOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded, color: backendOnline ? green : amber), const SizedBox(width: 10), Expanded(child: Text(backendOnline ? 'Engine CSI conectado. Dados recebidos do sensor.' : 'Nenhum sensor CSI conectado. O mapa permanece neutro até receber dados reais.', style: const TextStyle(color: Colors.white54, fontSize: 11))), const Icon(Icons.lock_outline_rounded, color: Colors.white38, size: 17)]));
}
