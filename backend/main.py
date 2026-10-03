import os
from typing import Any, Literal

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="SUNYA AI", version="2.0.0")


class ChatRequest(BaseModel):
    message: str
    provider: Literal["sunya", "chatgpt", "gemini", "claude"] = "sunya"
    context: dict[str, Any] = Field(default_factory=dict)


def build_prompt(request: ChatRequest) -> str:
    return f"""You are the {request.provider.upper()} intelligence layer inside SUNYA, a personal health operating system.
Analyze the supplied tracked information as a whole rather than answering from one metric.
Separate measured data, derived estimates and recommendations.
Never invent missing measurements. Do not diagnose disease or present medical conclusions as certainty.
If values may be concerning, explain that they require appropriate professional evaluation.
Prefer practical, personalized next actions and explain the relevant evidence from the user's own data.

USER HEALTH CONTEXT:
{request.context}

USER QUESTION:
{request.message}
"""


@app.get("/health")
def health():
    return {"status": "ok", "service": "sunya-ai", "version": "2.0.0"}


async def gemini(prompt: str) -> str:
    key = os.getenv("GEMINI_API_KEY", "").strip()
    if not key:
        raise RuntimeError("GEMINI_API_KEY is not configured")
    from google import genai
    client = genai.Client(api_key=key)
    response = await client.aio.models.generate_content(
        model=os.getenv("GEMINI_MODEL", "gemini-2.5-flash"),
        contents=prompt,
    )
    return response.text or "I could not generate an answer right now."


async def openai(prompt: str) -> str:
    key = os.getenv("OPENAI_API_KEY", "").strip()
    if not key:
        raise RuntimeError("OPENAI_API_KEY is not configured")
    async with httpx.AsyncClient(timeout=45) as client:
        response = await client.post(
            "https://api.openai.com/v1/responses",
            headers={"Authorization": f"Bearer {key}"},
            json={"model": os.getenv("OPENAI_MODEL", "gpt-5-mini"), "input": prompt},
        )
        response.raise_for_status()
        data = response.json()
        return data.get("output_text") or "I could not generate an answer right now."


async def claude(prompt: str) -> str:
    key = os.getenv("ANTHROPIC_API_KEY", "").strip()
    if not key:
        raise RuntimeError("ANTHROPIC_API_KEY is not configured")
    async with httpx.AsyncClient(timeout=45) as client:
        response = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={
                "model": os.getenv("ANTHROPIC_MODEL", "claude-sonnet-4-5"),
                "max_tokens": 1200,
                "messages": [{"role": "user", "content": prompt}],
            },
        )
        response.raise_for_status()
        data = response.json()
        blocks = data.get("content", [])
        return "".join(block.get("text", "") for block in blocks if block.get("type") == "text") or "I could not generate an answer right now."



@app.get("/v1/ai/providers")
def providers():
    return {
        "chatgpt": {"available": bool(os.getenv("OPENAI_API_KEY", "").strip()), "tier": "free"},
        "gemini": {"available": bool(os.getenv("GEMINI_API_KEY", "").strip()), "tier": "free"},
        "claude": {"available": bool(os.getenv("ANTHROPIC_API_KEY", "").strip()), "tier": "free"},
        "sunya": {"available": bool(os.getenv("GEMINI_API_KEY", "").strip()), "tier": "premium"},
    }


class GoogleAuthRequest(BaseModel):
    id_token: str


@app.post("/v1/auth/google")
async def google_auth(request: GoogleAuthRequest):
    client_id = os.getenv("GOOGLE_WEB_CLIENT_ID", "").strip()
    if not client_id:
        raise HTTPException(status_code=503, detail="Google authentication is not configured")
    try:
        from google.auth.transport import requests as google_requests
        from google.oauth2 import id_token as google_id_token

        claims = google_id_token.verify_oauth2_token(
            request.id_token,
            google_requests.Request(),
            client_id,
        )
        return {
            "id": claims.get("sub"),
            "email": claims.get("email"),
            "name": claims.get("name"),
            "picture": claims.get("picture"),
        }
    except Exception as exc:
        raise HTTPException(status_code=401, detail="Invalid Google identity token") from exc


@app.post("/v1/ai/chat")
async def chat(request: ChatRequest):
    try:
        prompt = build_prompt(request)
        if request.provider in ("sunya", "gemini"):
            text = await gemini(prompt)
        elif request.provider == "chatgpt":
            text = await openai(prompt)
        else:
            text = await claude(prompt)
        return {"text": text, "provider": request.provider}
    except httpx.HTTPStatusError as exc:
        raise HTTPException(status_code=502, detail=f"{request.provider} provider request failed") from exc
    except Exception as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
