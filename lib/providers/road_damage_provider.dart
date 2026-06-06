import 'package:flutter/foundation.dart';
import '../models/road_damage.dart';
import '../services/road_damage_service.dart';

enum LoadState { idle, loading, loaded, error }

class RoadDamageProvider extends ChangeNotifier {
  final RoadDamageService _service = RoadDamageService();

  RoadDamageSummary? _summary;
  DamageSeverity? _filterSeverity;
  DamageStatus?   _filterStatus;
  LoadState _state = LoadState.idle;
  String? _error;
  bool _submitSuccess = false;

  // ── Getters ──────────────────────────────────────────────
  RoadDamageSummary? get summary       => _summary;
  LoadState          get state         => _state;
  String?            get error         => _error;
  bool               get isLoading     => _state == LoadState.loading;
  bool               get submitSuccess => _submitSuccess;
  DamageSeverity?    get filterSeverity => _filterSeverity;
  DamageStatus?      get filterStatus   => _filterStatus;

  List<RoadDamageReport> get filteredReports {
    if (_summary == null) return [];
    var reports = _summary!.reports;
    if (_filterSeverity != null) {
      reports = reports.where((r) => r.severity == _filterSeverity).toList();
    }
    if (_filterStatus != null) {
      reports = reports.where((r) => r.status == _filterStatus).toList();
    }
    // Sort: critical first
    reports.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return reports;
  }

  // ── Init ─────────────────────────────────────────────────
  Future<void> init() async => load();

  // ── Load ─────────────────────────────────────────────────
  Future<void> load() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _summary = await _service.getSummary();
      _state   = LoadState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }

  // ── Submit report ─────────────────────────────────────────
  Future<bool> submitReport(RoadDamageReport report) async {
    _state = LoadState.loading;
    notifyListeners();

    try {
      final created = await _service.submitReport(report);
      // Optimistically add to local list
      if (_summary != null) {
        final updated = RoadDamageSummary(
          total:    _summary!.total + 1,
          critical: _summary!.critical + (created.severity == DamageSeverity.critical ? 1 : 0),
          high:     _summary!.high     + (created.severity == DamageSeverity.high     ? 1 : 0),
          medium:   _summary!.medium   + (created.severity == DamageSeverity.medium   ? 1 : 0),
          low:      _summary!.low      + (created.severity == DamageSeverity.low      ? 1 : 0),
          resolved: _summary!.resolved,
          pending:  _summary!.pending + 1,
          reports:  [created, ..._summary!.reports],
        );
        _summary = updated;
      }
      _submitSuccess = true;
      _state         = LoadState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = LoadState.error;
      notifyListeners();
      return false;
    }
  }

  // ── Filters ───────────────────────────────────────────────
  void setSeverityFilter(DamageSeverity? s) {
    _filterSeverity = s;
    notifyListeners();
  }

  void setStatusFilter(DamageStatus? s) {
    _filterStatus = s;
    notifyListeners();
  }

  void clearFilters() {
    _filterSeverity = null;
    _filterStatus   = null;
    notifyListeners();
  }

  void dismissSuccess() {
    _submitSuccess = false;
    notifyListeners();
  }
}