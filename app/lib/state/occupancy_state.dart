import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/occupancy_snapshot.dart';
import '../services/people_counter_service.dart';

class OccupancyState extends ChangeNotifier {
  final PeopleCounterService service;
  OccupancySnapshot snapshot = OccupancySnapshot.empty();
  bool backendOnline = false;
  bool demoMode = false;
  StreamSubscription<OccupancySnapshot>? _subscription;

  OccupancyState({PeopleCounterService? service}) : service = service ?? PeopleCounterService();

  void startDemoStream() {
    demoMode = true;
    var people = 0;
    var tick = 0;
    _subscription?.cancel();
    _subscription = Stream<OccupancySnapshot>.periodic(const Duration(seconds: 2), (_) {
      tick++;
      people = (people + (tick.isEven ? 7 : 3)) % 180;
      return OccupancySnapshot(
        timestamp: DateTime.now(),
        people: people,
        enteringPerMinute: tick.isEven ? 12 : 8,
        leavingPerMinute: tick.isEven ? 5 : 4,
        confidence: 0.78 + ((tick % 5) * 0.03),
        zones: {
          'Entrada': (people * .16).round(),
          'Pista': (people * .62).round(),
          'Camarote': (people * .22).round(),
        },
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
