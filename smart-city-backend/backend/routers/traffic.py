import asyncio
from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect
from models.traffic_models import TrafficResponse
from services import traffic_store
from ws.connection_manager import traffic_manager

router = APIRouter()

# How often (seconds) to push live traffic updates over WebSocket
_PUSH_INTERVAL = 5


@router.get("", response_model=TrafficResponse)
async def get_traffic():
    points = traffic_store.get_all_traffic()
    return TrafficResponse(points=points, total=len(points))


@router.get("/{point_id}")
async def get_traffic_point(point_id: str):
    point = traffic_store.get_traffic_by_id(point_id)
    if not point:
        raise HTTPException(status_code=404, detail="Traffic point not found")
    return point


@router.websocket("/ws")
async def traffic_ws(websocket: WebSocket):
    await traffic_manager.connect(websocket)
    # Send current snapshot immediately on connect
    points = traffic_store.get_all_traffic()
    await traffic_manager.send_personal(
        {
            "event": "initial_state",
            "points": [p.model_dump(mode="json") for p in points],
            "total": len(points),
        },
        websocket,
    )
    try:
        while True:
            # Push a live update every _PUSH_INTERVAL seconds.
            # Also keep reading so we detect client disconnect quickly.
            await asyncio.sleep(_PUSH_INTERVAL)
            updated = traffic_store.get_all_traffic()
            await traffic_manager.broadcast(
                {
                    "event": "traffic_update",
                    "points": [p.model_dump(mode="json") for p in updated],
                    "total": len(updated),
                }
            )
    except WebSocketDisconnect:
        traffic_manager.disconnect(websocket)
    except Exception:
        traffic_manager.disconnect(websocket)