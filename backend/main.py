import os
from typing import Any

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="SUNYA AI", version="2.0.0")


class ChatRequest(BaseModel):
    provider: str = "sunya"
    message: str
    context: dict[str, Any] = Field(default_factory=dict)


def _prompt(request: ChatRequest) -> str:
    return f"""You are SUNYA, a personal health and wellness intelligence assistant.
Analyze the supplied tracked and user-entered context thoroughly, but never invent missing measurements.
Distinguish measured data, user-entered data, calculations and recommendations.
Do not diagnose disease or present a medical conclusion as certainty.
For potentially concerning measurements, explain that a qualified clinician should evaluate them.
Look for relationships across sleep, activity, body composition, hydration, nutrition, recovery and trends when the data supports them.
Return practical, personalized guidance.

HEALTH CONTEXT:
{request.context}

USER QUESTION:
{request.message}
"""


async def _gemini(prompt: str, model: str) -> str:
    from google import genai

    key = os.getenv("GEMINI_API_KEY", "").strip()
    if not key:
        raise RuntimeError("Gemini provider is not configured")
    client = genai.Client(api_key=key)
    response = await client.aio.models.generate_content(model=model, contents=prompt)
    return response.text or "I could not generate an answer right now."


async def _openai(prompt: str, model: str) -> str:
    key = os.getenv("OPENAI_API_KEY", "").strip()
    if not key:
        raise RuntimeError("ChatGPT provider is not configured")
    async with httpx.AsyncClient(timeout=45) as client:
        response = await client.post(
            "https://api.openai.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            json={"model": model, "messages": [{"role": "system", "content": prompt}]},
        )
        response.raise_for_status()
        return response.json()["choices"][0]["message"]["content"]


async def _claude(prompt: str, model: str) -> str:
    key = os.getenv("ANTHROPIC_API_KEY", "").strip()
    if not key:
        raise RuntimeError("Claude provider is not configured")
    async with httpx.AsyncClient(timeout=45) as client:
        response = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={"model": model, "max_tokens": 1200, "messages": [{"role": "user", "content": prompt}]},
        )
        response.raise_for_status()
        data = response.json()
        return "".join(part.get("text", "") for part in data.get("content", []))


@app.get("/health")
def health():
    return {"status": "ok", "service": "sunya-ai"}


@app.post("/v1/ai/chat")
async def chat(request: ChatRequest):
    provider = request.provider.lower().strip()
    prompt = _prompt(request)
    try:
        if provider == "chatgpt":
            text = await _openai(prompt, os.getenv("OPENAI_MODEL", "gpt-5-mini"))
        elif provider == "claude":
            text = await _claude(prompt, os.getenv("ANTHROPIC_MODEL", "claude-sonnet-4-5"))
        elif provider in {"gemini", "sunya"}:
            text = await _gemini(
                prompt,
                os.getenv("SUNYA_GEMINI_MODEL" if provider == "sunya" else "GEMINI_MODEL", "gemini-2.5-flash"),
            )
        else:
            raise HTTPException(status_code=400, detail="Unsupported AI provider")
        return {"provider": provider, "text": text}
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=502, detail="AI provider request failed") from exc
