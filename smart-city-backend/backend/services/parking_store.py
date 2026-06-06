from typing import Dict, Optional
from models.parking_models import ParkingSlot
from datetime import datetime
import uuid

# Pre-seed parking slots for a city grid (lat/lon near a city center)
_BASE_LAT = 16.5062
_BASE_LON = 80.6480

PARKING_SLOTS: Dict[str, ParkingSlot] = {}

def _init_slots():
    zones = ["A", "B", "C", "D"]
    for z_idx, zone in enumerate(zones):
        for i in range(1, 6):
            slot_id = f"{zone}{i}"
            PARKING_SLOTS[slot_id] = ParkingSlot(
                slot_id=slot_id,
                zone=zone,
                is_occupied=False,
                vehicle_number=None,
                occupied_since=None,
                lat=_BASE_LAT + (z_idx * 0.002) + (i * 0.0003),
                lon=_BASE_LON + (z_idx * 0.003) + (i * 0.0002),
            )

_init_slots()


def get_all_slots():
    return list(PARKING_SLOTS.values())


def get_slot(slot_id: str) -> Optional[ParkingSlot]:
    return PARKING_SLOTS.get(slot_id)


def book_slot(slot_id: str, vehicle_number: str) -> Optional[ParkingSlot]:
    slot = PARKING_SLOTS.get(slot_id)
    if slot is None or slot.is_occupied:
        return None
    slot.is_occupied = True
    slot.vehicle_number = vehicle_number
    slot.occupied_since = datetime.utcnow()
    PARKING_SLOTS[slot_id] = slot
    return slot


def release_slot(slot_id: str) -> Optional[ParkingSlot]:
    slot = PARKING_SLOTS.get(slot_id)
    if slot is None or not slot.is_occupied:
        return None
    slot.is_occupied = False
    slot.vehicle_number = None
    slot.occupied_since = None
    PARKING_SLOTS[slot_id] = slot
    return slot


def available_count() -> int:
    return sum(1 for s in PARKING_SLOTS.values() if not s.is_occupied)