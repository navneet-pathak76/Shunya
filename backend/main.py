import os
from typing import Any

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="SUNYA AI", version="1.0.0")


class ChatRequest(BaseModel):
    message: str
    context: dict[str, Any] = {}


@app.get("/health")
def health():
    return {"status": "ok", "service": "sunya-ai"}


@app.post("/v1/ai/chat")
async def chat(request: ChatRequest):
    api_key = os.getenv("GEMINI_API_KEY", "").strip()
    if not api_key:
        raise HTTPException(status_code=503, detail="AI provider is not configured")

    try:
        from google import genai

        client = genai.Client(api_key=api_key)
        prompt = f"""You are SUNYA, a personal health and wellness assistant.
Use the supplied user context to personalize the answer.
Never invent missing measurements. Clearly distinguish tracked data from estimates.
Do not diagnose disease or present medical conclusions as certainty.
For potentially concerning medical values, recommend appropriate professional care.

USER HEALTH CONTEXT:
{request.context}

USER QUESTION:
{request.message}

Give a concise, practical answer. Mention the relevant tracked measurements when useful."""
        response = await client.aio.models.generate_content(
            model=os.getenv("GEMINI_MODEL", "gemini-2.5-flash"),
            contents=prompt,
        )
        return {"text": response.text or "I could not generate an answer right now."}
    except Exception as exc:
        raise HTTPException(status_code=502, detail="AI provider request failed") from exc
