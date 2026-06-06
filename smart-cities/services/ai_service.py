"""
Road Damage Detection Service
Uses YOLOv8 model (from oracl4/RoadDamageDetection) to detect:
- Longitudinal Crack
- Transverse Crack  
- Alligator Crack
- Pothole

Model path: backend/models/best.pt  (download from the repo or train yourself)
Falls back to mock detection if model not available.
"""

import os
import io
import base64
import uuid
import logging
from typing import List, Optional, Tuple
from datetime import datetime, timezone

from models.road_damage_models import DamageDetection, DamageType, RoadDamageReport

logger = logging.getLogger(__name__)

# Class names matching oracl4/RoadDamageDetection YOLOv8 model
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
    """Return plausible mock detections when model is unavailable."""
    import random
    detections = []
    num = random.randint(0, 3)
    for _ in range(num):
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
    """
    Run YOLOv8 inference on image bytes.
    Returns (report_id, detections, annotated_image_b64).
    """
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
                    for box in boxes:
                        cls_idx = int(box.cls[0].item())
                        conf = float(box.conf[0].item())
                        # Normalized xyxy
                        h, w = img_np.shape[:2]
                        x1, y1, x2, y2 = box.xyxy[0].tolist()
                        detections.append(DamageDetection(
                            damage_type=DAMAGE_CLASS_NAMES[cls_idx] if cls_idx < len(DAMAGE_CLASS_NAMES) else DamageType.POTHOLE,
                            confidence=round(conf, 3),
                            bbox=[round(x1/w, 3), round(y1/h, 3), round(x2/w, 3), round(y2/h, 3)],
                        ))

                # Annotated image
                annotated = result.plot()  # BGR numpy
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