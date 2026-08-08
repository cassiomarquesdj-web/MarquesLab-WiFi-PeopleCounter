import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/occupancy_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OccupancyState>();
    final s = state.snapshot;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PEOPLE COUNTER', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            Text('MarquesLab • Wi-Fi Sensing', style: TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Alternar fonte de dados',
            onPressed: () => state.demoMode ? state.startBackendStream() : state.startDemoStream(),
            icon: Icon(state.demoMode ? Icons.cloud_outlined : Icons.science_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => state.startBackendStream(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
          children: [
            _SystemBanner(online: state.backendOnline, demo: state.demoMode),
            const SizedBox(height: 14),
            _OccupancyHero(value: s.people, confidence: s.confidence, primary: primary),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _Metric(title: 'ENTRANDO', value: '+${s.enteringPerMinute}/min', icon: Icons.arrow_downward_rounded, primary: primary)),
                const SizedBox(width: 10),
                Expanded(child: _Metric(title: 'SAINDO', value: '-${s.leavingPerMinute}/min', icon: Icons.arrow_upward_rounded, primary: primary)),
              ],
            ),
            const SizedBox(height: 14),
            _ZonePanel(zones: s.zones, primary: primary),
            const SizedBox(height: 14),
            _SensorPanel(count: s.activeSensors),
            const SizedBox(height: 14),
            Text('Atualizado ${_time(s.timestamp)}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _time(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
}

class _SystemBanner extends StatelessWidget {
  final bool online;
  final bool demo;
  const _SystemBanner({required this.online, required this.demo});

  @override
  Widget build(BuildContext context) {
    final color = demo ? Colors.amber : (online ? Colors.greenAccent : Colors.white38);
    final text = demo ? 'MODO DEMONSTRAÇÃO' : (online ? 'ENGINE ONLINE' : 'AGUARDANDO ENGINE');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: color.withValues(alpha: .08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: .25))),
      child: Row(children: [Icon(Icons.circle, size: 10, color: color), const SizedBox(width: 10), Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)), const Spacer(), const Text('CSI', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w700))]),
    );
  }
}

class _OccupancyHero extends StatelessWidget {
  final int value;
  final double confidence;
  final Color primary;
  const _OccupancyHero({required this.value, required this.confidence, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PESSOAS PRESENTES', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('$value', style: const TextStyle(fontSize: 58, fontWeight: FontWeight.w900)), const SizedBox(width: 12), Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('${(confidence * 100).round()}% confiança', style: TextStyle(color: primary, fontWeight: FontWeight.w700)))]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: confidence, minHeight: 7)),
        ]),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color primary;
  const _Metric({required this.title, required this.value, required this.icon, required this.primary});

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: primary, size: 20), const SizedBox(height: 10), Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))])));
}

class _ZonePanel extends StatelessWidget {
  final Map<String, int> zones;
  final Color primary;
  const _ZonePanel({required this.zones, required this.primary});

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('OCUPAÇÃO POR ZONA', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)), const SizedBox(height: 14), ...zones.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: Text(e.key)), Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(width: 10), SizedBox(width: 90, child: LinearProgressIndicator(value: (e.value / 200).clamp(0, 1), color: primary))])))])));
}

class _SensorPanel extends StatelessWidget {
  final int count;
  const _SensorPanel({required this.count});

  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: const Icon(Icons.sensors_outlined), title: const Text('Sensores CSI ativos'), subtitle: const Text('Nós distribuídos pelo ambiente'), trailing: Text('$count', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))));
}
