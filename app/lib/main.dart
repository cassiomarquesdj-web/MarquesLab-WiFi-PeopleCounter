import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/occupancy_state.dart';
import 'ui/dashboard_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => OccupancyState()..startDemoStream(),
      child: const PeopleCounterApp(),
    ),
  );
}

class PeopleCounterApp extends StatelessWidget {
  const PeopleCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarquesLab People Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080A0D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF36E58D),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}
