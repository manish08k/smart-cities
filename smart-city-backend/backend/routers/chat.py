from fastapi import APIRouter, HTTPException
from models.chat_models import ChatRequest, ChatResponse, ChatMessage
from services.ai_service import chat_with_ai

router = APIRouter()


@router.post("", response_model=ChatResponse)
async def chat(req: ChatRequest):
    if not req.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty")
    reply = await chat_with_ai(req.message, req.history or [])
    return ChatResponse(reply=reply, role="assistant")


@router.get("/health")
async def chat_health():
    return {"status": "ok", "service": "chat"}