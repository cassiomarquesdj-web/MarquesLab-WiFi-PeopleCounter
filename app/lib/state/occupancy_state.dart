import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/occupancy_snapshot.dart';
import '../services/people_counter_service.dart';

class OccupancyState extends ChangeNotifier {
  final PeopleCounterService service;
  OccupancySnapshot snapshot = OccupancySnapshot.empty();
  bool backendOnline = false;
  bool demoMode = false;
  bool securityArmed = false;
  StreamSubscription<OccupancySnapshot>? _subscription;

  OccupancyState({PeopleCounterService? service}) : service = service ?? PeopleCounterService();

  void toggleSecurity() {
    securityArmed = !securityArmed;
    notifyListeners();
  }

  void startDemoStream() {
    demoMode = true;
    var tick = 0;
    _subscription?.cancel();
    _subscription = Stream<OccupancySnapshot>.periodic(const Duration(seconds: 2), (_) {
      tick++;
      final people = 5 + (tick % 4);
      final heatmap = List<double>.generate(48, (i) {
        final x = i % 8;
        final y = i ~/ 8;
        final a = 0.75 * (1 - ((x - 2.0).abs() + (y - 2.0).abs()) / 8).clamp(0, 1);
        final b = 0.55 * (1 - ((x - 6.0).abs() + (y - 4.0).abs()) / 8).clamp(0, 1);
        return (a + b).clamp(0, 1).toDouble();
      });
      return OccupancySnapshot(
        timestamp: DateTime.now(),
        people: people,
        enteringPerMinute: tick.isEven ? 2 : 1,
        leavingPerMinute: tick.isEven ? 0 : 1,
        confidence: .90,
        signalQuality: .92,
        presenceDetected: true,
        motionDetected: tick.isEven,
        zones: {'Entrada': 1, 'Pista': 3 + (tick % 2), 'Camarote': 1},
        heatmap: heatmap,
        activeSensors: 3,
      );
    }).listen((next) {
      snapshot = next;
      backendOnline = false;
      notifyListeners();
    });
  }

  void startBackendStream() {
    demoMode = false;
    _subscription?.cancel();
    _subscription = service.watch().listen((next) {
      snapshot = next;
      backendOnline = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
