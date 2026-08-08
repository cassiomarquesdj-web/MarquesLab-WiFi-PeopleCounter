class OccupancySnapshot {
  final DateTime timestamp;
  final int people;
  final int enteringPerMinute;
  final int leavingPerMinute;
  final double confidence;
  final Map<String, int> zones;
  final int activeSensors;

  const OccupancySnapshot({
    required this.timestamp,
    required this.people,
    required this.enteringPerMinute,
    required this.leavingPerMinute,
    required this.confidence,
    required this.zones,
    required this.activeSensors,
  });

  factory OccupancySnapshot.empty() => OccupancySnapshot(
        timestamp: DateTime.now(),
        people: 0,
        enteringPerMinute: 0,
        leavingPerMinute: 0,
        confidence: 0,
        zones: const {'Entrada': 0, 'Pista': 0, 'Camarote': 0},
        activeSensors: 0,
      );

  factory OccupancySnapshot.fromJson(Map<String, dynamic> json) {
    final rawZones = json['zones'] as Map<String, dynamic>? ?? {};
    return OccupancySnapshot(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      people: (json['people'] as num?)?.round() ?? 0,
      enteringPerMinute: (json['entering_per_minute'] as num?)?.round() ?? 0,
      leavingPerMinute: (json['leaving_per_minute'] as num?)?.round() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      zones: rawZones.map((key, value) => MapEntry(key, (value as num).round())),
      activeSensors: (json['active_sensors'] as num?)?.round() ?? 0,
    );
  }
}
