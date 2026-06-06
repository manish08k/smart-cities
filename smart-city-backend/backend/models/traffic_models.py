from pydantic import BaseModel
from typing import List
from enum import Enum


class TrafficLevel(str, Enum):
    LOW = "low"
    MODERATE = "moderate"
    HIGH = "high"
    SEVERE = "severe"


class TrafficPoint(BaseModel):
    point_id: str
    name: str
    lat: float
    lon: float
    level: TrafficLevel
    vehicle_count: int
    avg_speed_kmh: float
    updated_at: str


class TrafficResponse(BaseModel):
    points: List[TrafficPoint]
    total: int