from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect
from typing import List
from models.parking_models import ParkingSlot, ParkingBookingRequest, ParkingReleaseRequest, ParkingResponse
from services import parking_store
from ws.connection_manager import parking_manager
import asyncio

router = APIRouter()


@router.get("/slots", response_model=List[ParkingSlot])
async def get_slots():
    return parking_store.get_all_slots()


@router.get("/slots/{slot_id}", response_model=ParkingSlot)
async def get_slot(slot_id: str):
    slot = parking_store.get_slot(slot_id)
    if not slot:
        raise HTTPException(status_code=404, detail="Slot not found")
    return slot


@router.get("/available-count")
async def available_count():
    return {"available": parking_store.available_count(), "total": len(parking_store.PARKING_SLOTS)}


@router.post("/book", response_model=ParkingResponse)
async def book_slot(req: ParkingBookingRequest):
    slot = parking_store.book_slot(req.slot_id, req.vehicle_number)
    if not slot:
        raise HTTPException(status_code=400, detail="Slot not available or not found")
    # Broadcast update to all WebSocket clients
    await parking_manager.broadcast({
        "event": "slot_updated",
        "slot": slot.model_dump(mode="json"),
        "available": parking_store.available_count(),
    })
    return ParkingResponse(success=True, message="Slot booked successfully", slot=slot)


@router.post("/release", response_model=ParkingResponse)
async def release_slot(req: ParkingReleaseRequest):
    slot = parking_store.release_slot(req.slot_id)
    if not slot:
        raise HTTPException(status_code=400, detail="Slot not occupied or not found")
    await parking_manager.broadcast({
        "event": "slot_updated",
        "slot": slot.model_dump(mode="json"),
        "available": parking_store.available_count(),
    })
    return ParkingResponse(success=True, message="Slot released successfully", slot=slot)


@router.websocket("/ws")
async def parking_ws(websocket: WebSocket):
    await parking_manager.connect(websocket)
    # Send current state on connect
    slots = [s.model_dump(mode="json") for s in parking_store.get_all_slots()]
    await parking_manager.send_personal({
        "event": "initial_state",
        "slots": slots,
        "available": parking_store.available_count(),
    }, websocket)
    try:
        while True:
            # Keep alive — clients can send pings
            data = await websocket.receive_text()
    except WebSocketDisconnect:
        parking_manager.disconnect(websocket)