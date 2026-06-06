from pydantic import BaseModel
from typing import List, Optional
from enum import Enum


class DamageType(str, Enum):
    LONGITUDINAL_CRACK = "Longitudinal Crack"
    TRANSVERSE_CRACK = "Transverse Crack"
    ALLIGATOR_CRACK = "Alligator Crack"
    POTHOLE = "Pothole"


class DamageDetection(BaseModel):
    damage_type: DamageType
    confidence: float
    bbox: List[float]  # [x1, y1, x2, y2] normalized


class RoadDamageReport(BaseModel):
    report_id: str
    lat: float
    lon: float
    address: Optional[str] = None
    detections: List[DamageDetection]
    image_url: Optional[str] = None
    reported_at: str
    status: str = "pending"


class RoadDamageDetectResponse(BaseModel):
    report_id: str
    detections: List[DamageDetection]
    annotated_image_b64: Optional[str] = None
    damage_count: int