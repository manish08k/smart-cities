from fastapi import APIRouter, File, UploadFile, Form, HTTPException
from typing import List, Optional
from models.road_damage_models import RoadDamageReport, RoadDamageDetectResponse
from services import road_damage_store
from services.ai_service import detect_road_damage, build_report

router = APIRouter()


@router.post("/detect", response_model=RoadDamageDetectResponse)
async def detect(
    file: UploadFile = File(...),
    lat: float = Form(...),
    lon: float = Form(...),
    address: Optional[str] = Form(None),
):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are accepted")

    image_bytes = await file.read()
    if len(image_bytes) > 10 * 1024 * 1024:  # 10MB limit
        raise HTTPException(status_code=413, detail="Image too large (max 10MB)")

    report_id, detections, annotated_b64 = detect_road_damage(image_bytes, lat, lon, address)
    report = build_report(report_id, lat, lon, detections, address)
    road_damage_store.save_report(report)

    return RoadDamageDetectResponse(
        report_id=report_id,
        detections=detections,
        annotated_image_b64=annotated_b64,
        damage_count=len(detections),
    )


@router.get("/reports", response_model=List[RoadDamageReport])
async def get_all_reports():
    return road_damage_store.get_all_reports()


@router.get("/reports/{report_id}", response_model=RoadDamageReport)
async def get_report(report_id: str):
    report = road_damage_store.get_report(report_id)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report


@router.patch("/reports/{report_id}/status")
async def update_status(report_id: str, status: str):
    valid = {"pending", "in_review", "resolved"}
    if status not in valid:
        raise HTTPException(status_code=400, detail=f"Status must be one of {valid}")
    report = road_damage_store.update_report_status(report_id, status)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return {"success": True, "report_id": report_id, "status": status}