enum DamageSeverity { low, medium, high, critical }
enum DamageStatus   { reported, acknowledged, inProgress, resolved }
enum DamageType     { pothole, crack, subsidence, flooding, debris, other }

DamageSeverity severityFromString(String s) {
  switch (s.toLowerCase()) {
    case 'critical': return DamageSeverity.critical;
    case 'high':     return DamageSeverity.high;
    case 'medium':   return DamageSeverity.medium;
    default:         return DamageSeverity.low;
  }
}

DamageStatus statusFromString(String s) {
  switch (s.toLowerCase()) {
    case 'acknowledged':  return DamageStatus.acknowledged;
    case 'in_progress':   return DamageStatus.inProgress;
    case 'resolved':      return DamageStatus.resolved;
    default:              return DamageStatus.reported;
  }
}

DamageType typeFromString(String s) {
  switch (s.toLowerCase()) {
    case 'pothole':    return DamageType.pothole;
    case 'crack':      return DamageType.crack;
    case 'subsidence': return DamageType.subsidence;
    case 'flooding':   return DamageType.flooding;
    case 'debris':     return DamageType.debris;
    default:           return DamageType.other;
  }
}

class RoadDamageReport {
  final String id;
  final String location;
  final double latitude;
  final double longitude;
  final DamageType type;
  final DamageSeverity severity;
  final DamageStatus status;
  final String description;
  final String reportedBy;
  final String reportedAt;
  final String? imageUrl;
  final String? resolvedAt;

  RoadDamageReport({
    required this.id,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.severity,
    required this.status,
    required this.description,
    required this.reportedBy,
    required this.reportedAt,
    this.imageUrl,
    this.resolvedAt,
  });

  factory RoadDamageReport.fromJson(Map<String, dynamic> json) {
    return RoadDamageReport(
      id:          json['id']           as String,
      location:    json['location']     as String,
      latitude:    (json['latitude']  as num).toDouble(),
      longitude:   (json['longitude'] as num).toDouble(),
      type:        typeFromString(json['type'] as String),
      severity:    severityFromString(json['severity'] as String),
      status:      statusFromString(json['status'] as String),
      description: json['description']  as String,
      reportedBy:  json['reported_by']  as String,
      reportedAt:  json['reported_at']  as String,
      imageUrl:    json['image_url']    as String?,
      resolvedAt:  json['resolved_at']  as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'location':    location,
    'latitude':    latitude,
    'longitude':   longitude,
    'type':        type.name,
    'severity':    severity.name,
    'description': description,
  };
}

class RoadDamageSummary {
  final int total;
  final int critical;
  final int high;
  final int medium;
  final int low;
  final int resolved;
  final int pending;
  final List<RoadDamageReport> reports;

  RoadDamageSummary({
    required this.total,
    required this.critical,
    required this.high,
    required this.medium,
    required this.low,
    required this.resolved,
    required this.pending,
    required this.reports,
  });

  factory RoadDamageSummary.fromJson(Map<String, dynamic> json) {
    return RoadDamageSummary(
      total:    json['total']    as int,
      critical: json['critical'] as int,
      high:     json['high']     as int,
      medium:   json['medium']   as int,
      low:      json['low']      as int,
      resolved: json['resolved'] as int,
      pending:  json['pending']  as int,
      reports: (json['reports'] as List<dynamic>)
          .map((r) => RoadDamageReport.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}