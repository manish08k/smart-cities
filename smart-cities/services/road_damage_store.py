from typing import Dict, List, Optional
from models.road_damage_models import RoadDamageReport
import uuid

ROAD_DAMAGE_REPORTS: Dict[str, RoadDamageReport] = {}


def save_report(report: RoadDamageReport) -> RoadDamageReport:
    ROAD_DAMAGE_REPORTS[report.report_id] = report
    return report


def get_all_reports() -> List[RoadDamageReport]:
    return list(ROAD_DAMAGE_REPORTS.values())


def get_report(report_id: str) -> Optional[RoadDamageReport]:
    return ROAD_DAMAGE_REPORTS.get(report_id)


def update_report_status(report_id: str, status: str) -> Optional[RoadDamageReport]:
    report = ROAD_DAMAGE_REPORTS.get(report_id)
    if report:
        report.status = status
        ROAD_DAMAGE_REPORTS[report_id] = report
    return report