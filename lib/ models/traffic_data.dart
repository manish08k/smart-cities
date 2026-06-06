enum TrafficLevel { free, light, moderate, heavy }

TrafficLevel trafficLevelFromString(String s) {
  switch (s.toLowerCase()) {
    case 'free':     return TrafficLevel.free;
    case 'light':    return TrafficLevel.light;
    case 'moderate': return TrafficLevel.moderate;
    case 'heavy':    return TrafficLevel.heavy;
    default:         return TrafficLevel.light;
  }
}

class TrafficSegment {
  final String id;
  final String roadName;
  final TrafficLevel level;
  final int speedKmh;
  final int usualSpeedKmh;
  final String direction;
  final String estimatedDelay;
  final String updatedAt;

  TrafficSegment({
    required this.id,
    required this.roadName,
    required this.level,
    required this.speedKmh,
    required this.usualSpeedKmh,
    required this.direction,
    required this.estimatedDelay,
    required this.updatedAt,
  });

  factory TrafficSegment.fromJson(Map<String, dynamic> json) {
    return TrafficSegment(
      id:             json['id']              as String,
      roadName:       json['road_name']       as String,
      level:          trafficLevelFromString(json['level'] as String),
      speedKmh:       json['speed_kmh']       as int,
      usualSpeedKmh:  json['usual_speed_kmh'] as int,
      direction:      json['direction']       as String,
      estimatedDelay: json['estimated_delay'] as String,
      updatedAt:      json['updated_at']      as String,
    );
  }

  int get congestionPercent {
    if (usualSpeedKmh == 0) return 0;
    final pct = ((usualSpeedKmh - speedKmh) / usualSpeedKmh * 100).round();
    return pct.clamp(0, 100);
  }
}

class TrafficSummary {
  final int totalSegments;
  final int freeCount;
  final int lightCount;
  final int moderateCount;
  final int heavyCount;
  final String overallStatus;
  final String updatedAt;
  final List<TrafficSegment> segments;

  TrafficSummary({
    required this.totalSegments,
    required this.freeCount,
    required this.lightCount,
    required this.moderateCount,
    required this.heavyCount,
    required this.overallStatus,
    required this.updatedAt,
    required this.segments,
  });

  factory TrafficSummary.fromJson(Map<String, dynamic> json) {
    return TrafficSummary(
      totalSegments: json['total_segments'] as int,
      freeCount:     json['free_count']     as int,
      lightCount:    json['light_count']    as int,
      moderateCount: json['moderate_count'] as int,
      heavyCount:    json['heavy_count']    as int,
      overallStatus: json['overall_status'] as String,
      updatedAt:     json['updated_at']     as String,
      segments: (json['segments'] as List<dynamic>)
          .map((s) => TrafficSegment.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}