import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/traffic_data.dart';
import '../services/traffic_service.dart';

enum LoadState { idle, loading, loaded, error }

class TrafficProvider extends ChangeNotifier {
  final TrafficService _service = TrafficService();

  TrafficSummary? _summary;
  List<Map<String, dynamic>> _hourlyData = [];
  TrafficLevel? _filterLevel;
  LoadState _state = LoadState.idle;
  String? _error;
  Timer? _autoRefreshTimer;

  // ── Getters ──────────────────────────────────────────────
  TrafficSummary? get summary    => _summary;
  LoadState       get state      => _state;
  String?         get error      => _error;
  bool            get isLoading  => _state == LoadState.loading;
  TrafficLevel?   get filterLevel => _filterLevel;
  List<Map<String, dynamic>> get hourlyData => _hourlyData;

  List<TrafficSegment> get filteredSegments {
    if (_summary == null) return [];
    if (_filterLevel == null) return _summary!.segments;
    return _summary!.segments.where((s) => s.level == _filterLevel).toList();
  }

  // ── Init ─────────────────────────────────────────────────
  Future<void> init() async {
    await load();
    // Auto-refresh every 60 seconds
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) => load());
  }

  // ── Load ─────────────────────────────────────────────────
  Future<void> load() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getSummary(),
        _service.getHourlyData(),
      ]);
      _summary    = results[0] as TrafficSummary;
      _hourlyData = results[1] as List<Map<String, dynamic>>;
      _state      = LoadState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }

  // ── Filter ────────────────────────────────────────────────
  void setFilter(TrafficLevel? level) {
    _filterLevel = level;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
