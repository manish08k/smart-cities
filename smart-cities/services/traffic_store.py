import random
from datetime import datetime, timezone
from models.traffic_models import TrafficPoint, TrafficLevel

_BASE_LAT = 16.5062
_BASE_LON = 80.6480

TRAFFIC_POINTS = [
    {"point_id": "T1", "name": "MG Road Junction", "lat": 16.5062, "lon": 80.6480},
    {"point_id": "T2", "name": "Bus Stand Circle", "lat": 16.5120, "lon": 80.6350},
    {"point_id": "T3", "name": "Railway Station Rd", "lat": 16.5200, "lon": 80.6550},
    {"point_id": "T4", "name": "Old Town Signal", "lat": 16.4980, "lon": 80.6600},
    {"point_id": "T5", "name": "Ring Road East", "lat": 16.5300, "lon": 80.6700},
    {"point_id": "T6", "name": "Market Area", "lat": 16.5050, "lon": 80.6200},
]


def _random_level(vehicle_count: int) -> TrafficLevel:
    if vehicle_count < 20:
        return TrafficLevel.LOW
    elif vehicle_count < 50:
        return TrafficLevel.MODERATE
    elif vehicle_count < 80:
        return TrafficLevel.HIGH
    return TrafficLevel.SEVERE


def get_all_traffic():
    result = []
    for tp in TRAFFIC_POINTS:
        vehicle_count = random.randint(5, 100)
        level = _random_level(vehicle_count)
        avg_speed = max(5.0, round(60 - vehicle_count * 0.5 + random.uniform(-5, 5), 1))
        result.append(TrafficPoint(
            point_id=tp["point_id"],
            name=tp["name"],
            lat=tp["lat"],
            lon=tp["lon"],
            level=level,
            vehicle_count=vehicle_count,
            avg_speed_kmh=avg_speed,
            updated_at=datetime.now(timezone.utc).isoformat(),
        ))
    return result


def get_traffic_by_id(point_id: str):
    all_traffic = get_all_traffic()
    for t in all_traffic:
        if t.point_id == point_id:
            return t
    return None