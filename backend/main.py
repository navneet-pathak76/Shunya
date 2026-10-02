import os
from typing import Any, Literal

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="SUNYA AI", version="2.0.0")

Provider = Literal["chatgpt", "gemini", "claude", "sunya"]


class ChatRequest(BaseModel):
    message: str
    provider: Provider = "sunya"
    context: dict[str, Any] = Field(default_factory=dict)


class GoogleAuthRequest(BaseModel):
    id_token: str


@app.get("/health")
def health():
    return {"status": "ok", "service": "sunya-ai", "version": "2.0.0"}


@app.get("/v1/ai/providers")
def providers():
    return {
        "chatgpt": bool(os.getenv("OPENAI_API_KEY")),
        "gemini": bool(os.getenv("GEMINI_API_KEY")),
        "claude": bool(os.getenv("ANTHROPIC_API_KEY")),
        "sunya": bool(os.getenv("SUNYA_AI_ENABLED", "true").lower() == "true")
        and bool(os.getenv("GEMINI_API_KEY")),
    }


@app.post("/v1/auth/google")
def google_auth(request: GoogleAuthRequest):
    audience = os.getenv("GOOGLE_WEB_CLIENT_ID", "").strip()
    if not audience:
        raise HTTPException(status_code=503, detail="Google backend client ID is not configured")
    try:
        from google.auth.transport import requests as google_requests
        from google.oauth2 import id_token

        info = id_token.verify_oauth2_token(
            request.id_token,
            google_requests.Request(),
            audience,
        )
        return {
            "id": info["sub"],
            "email": info.get("email"),
            "name": info.get("name"),
            "emailVerified": bool(info.get("email_verified")),
        }
    except Exception as exc:
        raise HTTPException(status_code=401, detail="Invalid Google identity token") from exc


def _health_system(provider: str) -> str:
    if provider == "sunya":
        return """You are SUNYA AI, a personal health intelligence system.
Analyze the user's supplied longitudinal health context as a connected system.
Prioritize trends, relationships between metrics, recovery, activity, sleep, hydration,
nutrition, body composition and user-entered notes. Distinguish measured data from
estimates. Never invent values. Do not diagnose disease. If data may indicate a
concerning medical issue, explain the measurement neutrally and recommend appropriate
professional care. Give practical next actions and state what additional data would
improve confidence."""
    return """You are an AI provider inside SUNYA, a personal health application.
Use the supplied health context to personalize the answer. Never invent missing
measurements. Distinguish tracked data from estimates. Do not diagnose disease or
present medical conclusions as certainty. Give concise, practical guidance."""


async def _chatgpt(message: str, context: dict[str, Any]) -> str:
    key = os.getenv("OPENAI_API_KEY", "").strip()
    if not key:
        raise HTTPException(status_code=503, detail="ChatGPT provider is not configured")
    model = os.getenv("OPENAI_MODEL", "gpt-5.6")
    payload = {
        "model": model,
        "input": [
            {"role": "system", "content": _health_system("chatgpt")},
            {"role": "user", "content": f"HEALTH CONTEXT:\n{context}\n\nQUESTION:\n{message}"},
        ],
        "store": False,
    }
    async with httpx.AsyncClient(timeout=60) as client:
        response = await client.post(
            "https://api.openai.com/v1/responses",
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            json=payload,
        )
    if response.status_code >= 400:
        raise HTTPException(status_code=502, detail="ChatGPT provider request failed")
    data = response.json()
    if data.get("output_text"):
        return data["output_text"]
    for item in data.get("output", []):
        for content in item.get("content", []):
            if content.get("type") == "output_text":
                return content.get("text", "")
    return "The provider returned no text."


async def _gemini(message: str, context: dict[str, Any], sunya: bool = False) -> str:
    key = os.getenv("GEMINI_API_KEY", "").strip()
    if not key:
        raise HTTPException(status_code=503, detail="Gemini provider is not configured")
    try:
        from google import genai
        client = genai.Client(api_key=key)
        model = os.getenv(
            "SUNYA_GEMINI_MODEL" if sunya else "GEMINI_MODEL",
            "gemini-2.5-flash",
        )
        response = await client.aio.models.generate_content(
            model=model,
            contents=f"{_health_system('sunya' if sunya else 'gemini')}\n\nHEALTH CONTEXT:\n{context}\n\nQUESTION:\n{message}",
        )
        return response.text or "The provider returned no text."
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=502, detail="Gemini provider request failed") from exc


async def _claude(message: str, context: dict[str, Any]) -> str:
    key = os.getenv("ANTHROPIC_API_KEY", "").strip()
    if not key:
        raise HTTPException(status_code=503, detail="Claude provider is not configured")
    model = os.getenv("CLAUDE_MODEL", "claude-sonnet-4-5")
    payload = {
        "model": model,
        "max_tokens": 1200,
        "system": _health_system("claude"),
        "messages": [
            {"role": "user", "content": f"HEALTH CONTEXT:\n{context}\n\nQUESTION:\n{message}"}
        ],
    }
    async with httpx.AsyncClient(timeout=60) as client:
        response = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json=payload,
        )
    if response.status_code >= 400:
        raise HTTPException(status_code=502, detail="Claude provider request failed")
    data = response.json()
    parts = data.get("content", [])
    return "".join(part.get("text", "") for part in parts if part.get("type") == "text") or "The provider returned no text."


@app.post("/v1/ai/chat")
async def chat(request: ChatRequest):
    if request.provider == "chatgpt":
        text = await _chatgpt(request.message, request.context)
    elif request.provider == "gemini":
        text = await _gemini(request.message, request.context)
    elif request.provider == "claude":
        text = await _claude(request.message, request.context)
    else:
        text = await _gemini(request.message, request.context, sunya=True)
    return {"text": text, "provider": request.provider}
