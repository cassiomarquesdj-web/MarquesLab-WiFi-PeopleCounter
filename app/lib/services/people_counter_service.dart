import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/occupancy_snapshot.dart';

class PeopleCounterService {
  final http.Client _client;
  final String baseUrl;

  PeopleCounterService({http.Client? client, this.baseUrl = 'http://10.0.2.2:8080'})
      : _client = client ?? http.Client();

  Future<OccupancySnapshot> fetchSnapshot() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/v1/occupancy'));
    if (response.statusCode != 200) {
      throw Exception('Servidor respondeu ${response.statusCode}');
    }
    return OccupancySnapshot.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Stream<OccupancySnapshot> watch({Duration interval = const Duration(seconds: 2)}) async* {
    while (true) {
      try {
        yield await fetchSnapshot();
      } catch (_) {
        // O estado da UI mantém o último snapshot quando o backend está offline.
      }
      await Future<void>.delayed(interval);
    }
  }
}
