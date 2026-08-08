import 'package:flutter/material.dart';

void main() {
  runApp(const PeopleCounterApp());
}

class PeopleCounterApp extends StatelessWidget {
  const PeopleCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi People Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF090B10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi People Counter'),
        actions: [
          IconButton(
            tooltip: 'Sensores',
            onPressed: () {},
            icon: const Icon(Icons.sensors_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _StatusCard(),
          SizedBox(height: 16),
          _OccupancyCard(),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _MetricCard(title: 'Entrando', value: '+32/min')),
              SizedBox(width: 12),
              Expanded(child: _MetricCard(title: 'Saindo', value: '-18/min')),
            ],
          ),
          SizedBox(height: 16),
          _ZoneCard(),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sistema online', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('MVP • aguardando sensores CSI', style: TextStyle(color: Colors.white60)),
                ],
              ),
            ),
            Text('0 sensores', style: TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  const _OccupancyCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pessoas presentes', style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 8),
            const Text('0', style: TextStyle(fontSize: 54, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Estimativa inicial', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 18),
            LinearProgressIndicator(value: 0),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Zonas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 16),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.login), title: Text('Entrada'), trailing: Text('0')),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.groups_outlined), title: Text('Pista'), trailing: Text('0')),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.table_bar_outlined), title: Text('Camarote'), trailing: Text('0')),
          ],
        ),
      ),
    );
  }
}
