from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class ParkingSlot(BaseModel):
    slot_id: str
    zone: str
    is_occupied: bool
    vehicle_number: Optional[str] = None
    occupied_since: Optional[datetime] = None
    lat: float
    lon: float


class ParkingBookingRequest(BaseModel):
    slot_id: str
    vehicle_number: str


class ParkingReleaseRequest(BaseModel):
    slot_id: str


class ParkingResponse(BaseModel):
    success: bool
    message: str
    slot: Optional[ParkingSlot] = None