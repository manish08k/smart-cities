import sys
import os

# Ensure the backend/ directory is on sys.path so all absolute imports resolve
# whether you run from the repo root or from inside smart-city-backend/backend/
sys.path.insert(0, os.path.dirname(__file__))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import parking, traffic, road_damage, chat

app = FastAPI(title="Smart City API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(parking.router,     prefix="/parking",     tags=["parking"])
app.include_router(traffic.router,     prefix="/traffic",     tags=["traffic"])
app.include_router(road_damage.router, prefix="/road-damage", tags=["road-damage"])
app.include_router(chat.router,        prefix="/chat",        tags=["chat"])


@app.get("/health")
async def health():
    return {"status": "ok", "service": "smart-city-backend"}


# ── Run directly: python main.py  OR  uvicorn main:app --reload ──────────────
if __name__ == "__main__":
    import uvicorn
    from dotenv import load_dotenv
    load_dotenv()
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)