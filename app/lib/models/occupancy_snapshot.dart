class OccupancySnapshot {
  final DateTime timestamp;
  final int people;
  final int enteringPerMinute;
  final int leavingPerMinute;
  final double confidence;
  final double signalQuality;
  final bool presenceDetected;
  final bool motionDetected;
  final Map<String, int> zones;
  final List<double> heatmap;
  final int activeSensors;

  const OccupancySnapshot({
    required this.timestamp,
    required this.people,
    required this.enteringPerMinute,
    required this.leavingPerMinute,
    required this.confidence,
    required this.signalQuality,
    required this.presenceDetected,
    required this.motionDetected,
    required this.zones,
    required this.heatmap,
    required this.activeSensors,
  });

  factory OccupancySnapshot.empty() => OccupancySnapshot(
        timestamp: DateTime.now(),
        people: 0,
        enteringPerMinute: 0,
        leavingPerMinute: 0,
        confidence: 0,
        signalQuality: 0,
        presenceDetected: false,
        motionDetected: false,
        zones: const {'Entrada': 0, 'Pista': 0, 'Camarote': 0},
        heatmap: List<double>.filled(48, 0),
        activeSensors: 0,
      );

  factory OccupancySnapshot.fromJson(Map<String, dynamic> json) {
    final rawZones = json['zones'] as Map<String, dynamic>? ?? {};
    final rawHeatmap = (json['heatmap'] as List<dynamic>? ?? const [])
        .map((value) => (value as num).toDouble())
        .toList();
    return OccupancySnapshot(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      people: (json['people'] as num?)?.round() ?? 0,
      enteringPerMinute: (json['entering_per_minute'] as num?)?.round() ?? 0,
      leavingPerMinute: (json['leaving_per_minute'] as num?)?.round() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      signalQuality: (json['signal_quality'] as num?)?.toDouble() ?? 0,
      presenceDetected: json['presence_detected'] == true,
      motionDetected: json['motion_detected'] == true,
      zones: rawZones.map((key, value) => MapEntry(key, (value as num).round())),
      heatmap: rawHeatmap.length == 48 ? rawHeatmap : List<double>.filled(48, 0),
      activeSensors: (json['active_sensors'] as num?)?.round() ?? 0,
    );
  }
}
