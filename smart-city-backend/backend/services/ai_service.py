"""
AI Service
----------
1. Road Damage Detection  — YOLOv8 (falls back to mock when model absent)
2. Chat                   — rule-based smart-city assistant (no external API needed)
"""

import os
import io
import base64
import random
import logging
from typing import List, Optional, Tuple
from datetime import datetime, timezone

from models.road_damage_models import DamageDetection, DamageType, RoadDamageReport
from models.chat_models import ChatMessage

logger = logging.getLogger(__name__)

# ─── Road damage ────────────────────────────────────────────────────────────

DAMAGE_CLASS_NAMES = [
    DamageType.LONGITUDINAL_CRACK,
    DamageType.TRANSVERSE_CRACK,
    DamageType.ALLIGATOR_CRACK,
    DamageType.POTHOLE,
]

_model = None
_model_loaded = False


def _load_model():
    global _model, _model_loaded
    if _model_loaded:
        return _model
    model_path = os.path.join(os.path.dirname(__file__), "..", "models", "best.pt")
    if os.path.exists(model_path):
        try:
            from ultralytics import YOLO
            _model = YOLO(model_path)
            logger.info("YOLOv8 road damage model loaded from %s", model_path)
        except Exception as e:
            logger.warning("Could not load YOLO model: %s. Using mock detection.", e)
            _model = None
    else:
        logger.warning("Model file not found at %s. Using mock detection.", model_path)
        _model = None
    _model_loaded = True
    return _model


def _mock_detect(image_bytes: bytes) -> Tuple[List[DamageDetection], Optional[str]]:
    detections = []
    for _ in range(random.randint(0, 3)):
        damage_type = random.choice(list(DamageType))
        detections.append(DamageDetection(
            damage_type=damage_type,
            confidence=round(random.uniform(0.55, 0.95), 2),
            bbox=[
                round(random.uniform(0.1, 0.4), 3),
                round(random.uniform(0.1, 0.4), 3),
                round(random.uniform(0.5, 0.9), 3),
                round(random.uniform(0.5, 0.9), 3),
            ],
        ))
    return detections, None


def detect_road_damage(
    image_bytes: bytes,
    lat: float,
    lon: float,
    address: Optional[str] = None,
) -> Tuple[str, List[DamageDetection], Optional[str]]:
    import uuid
    report_id = str(uuid.uuid4())
    model = _load_model()
    annotated_b64: Optional[str] = None
    detections: List[DamageDetection] = []

    if model is not None:
        try:
            import numpy as np
            from PIL import Image
            import cv2

            img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
            img_np = np.array(img)
            results = model.predict(img_np, conf=0.25, verbose=False)

            for result in results:
                boxes = result.boxes
                if boxes is not None:
                    h, w = img_np.shape[:2]
                    for box in boxes:
                        cls_idx = int(box.cls[0].item())
                        conf = float(box.conf[0].item())
                        x1, y1, x2, y2 = box.xyxy[0].tolist()
                        detections.append(DamageDetection(
                            damage_type=DAMAGE_CLASS_NAMES[cls_idx] if cls_idx < len(DAMAGE_CLASS_NAMES) else DamageType.POTHOLE,
                            confidence=round(conf, 3),
                            bbox=[round(x1/w, 3), round(y1/h, 3), round(x2/w, 3), round(y2/h, 3)],
                        ))
                annotated = result.plot()
                _, buf = cv2.imencode(".jpg", annotated)
                annotated_b64 = base64.b64encode(buf.tobytes()).decode()
        except Exception as e:
            logger.error("YOLO inference failed: %s. Falling back to mock.", e)
            detections, annotated_b64 = _mock_detect(image_bytes)
    else:
        detections, annotated_b64 = _mock_detect(image_bytes)

    return report_id, detections, annotated_b64


def build_report(
    report_id: str,
    lat: float,
    lon: float,
    detections: List[DamageDetection],
    address: Optional[str] = None,
) -> RoadDamageReport:
    return RoadDamageReport(
        report_id=report_id,
        lat=lat,
        lon=lon,
        address=address,
        detections=detections,
        reported_at=datetime.now(timezone.utc).isoformat(),
        status="pending",
    )


# ─── Chat ────────────────────────────────────────────────────────────────────

_SMART_CITY_CONTEXT = """
You are a helpful Smart City assistant for Vijayawada, Andhra Pradesh.
You help citizens with parking, traffic, road damage reports, and general city services.
Keep answers concise and practical.
"""

_KEYWORD_REPLIES = {
    ("parking", "park", "slot", "vehicle"): (
        "You can check available parking slots in real time on the Parking screen. "
        "Tap a free slot on the map to book it instantly."
    ),
    ("traffic", "jam", "congestion", "signal", "road"): (
        "Live traffic levels are visible on the Traffic screen. "
        "Green = low, Yellow = moderate, Red = high/severe. Updates every 5 seconds."
    ),
    ("damage", "pothole", "crack", "repair", "broken"): (
        "Use the Road Damage screen to upload a photo. "
        "Our AI will detect the damage type and log a report for the city maintenance team."
    ),
    ("emergency", "police", "ambulance", "fire"): (
        "For emergencies dial 112. "
        "Police: 100 | Ambulance: 108 | Fire: 101."
    ),
    ("hello", "hi", "hey", "namaste"): (
        "Hello! I'm your Smart City assistant for Vijayawada. "
        "Ask me about parking, traffic, road damage, or any city service."
    ),
}


async def chat_with_ai(message: str, history: List[ChatMessage]) -> str:
    """
    Simple keyword-based smart city assistant.
    Swap this body for an LLM call when an API key is available.
    """
    lower = message.lower()
    for keywords, reply in _KEYWORD_REPLIES.items():
        if any(kw in lower for kw in keywords):
            return reply

    # Generic fallback
    return (
        "I'm your Vijayawada Smart City assistant. "
        "I can help with parking availability, live traffic updates, "
        "road damage reporting, and emergency contacts. "
        "What would you like to know?"
    )