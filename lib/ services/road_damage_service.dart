import '../core/api_client.dart';
import '../models/road_damage.dart';

class RoadDamageService {
  final ApiClient _client = ApiClient.instance;

  // ── Get summary + all reports ─────────────────────────────
  Future<RoadDamageSummary> getSummary() async {
    final response = await _client.get('/road-damage/summary');
    return RoadDamageSummary.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Get all reports ───────────────────────────────────────
  Future<List<RoadDamageReport>> getReports({
    DamageSeverity? severity,
    DamageStatus? status,
  }) async {
    final params = <String, dynamic>{};
    if (severity != null) params['severity'] = severity.name;
    if (status   != null) params['status']   = status.name;

    final response = await _client.get('/road-damage/reports', queryParams: params);
    return (response.data as List<dynamic>)
        .map((r) => RoadDamageReport.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── Get single report ─────────────────────────────────────
  Future<RoadDamageReport> getReport(String id) async {
    final response = await _client.get('/road-damage/reports/$id');
    return RoadDamageReport.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Submit new report ─────────────────────────────────────
  Future<RoadDamageReport> submitReport(RoadDamageReport report) async {
    final response = await _client.post('/road-damage/reports', data: report.toJson());
    return RoadDamageReport.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Update status ─────────────────────────────────────────
  Future<RoadDamageReport> updateStatus(String id, DamageStatus status) async {
    final response = await _client.patch(
      '/road-damage/reports/$id/status',
      data: {'status': status.name},
    );
    return RoadDamageReport.fromJson(response.data as Map<String, dynamic>);
  }
}