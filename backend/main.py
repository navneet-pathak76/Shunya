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


SYSTEM_PROMPT = """You are SUNYA, a personal health intelligence assistant.
Analyze the user's supplied health, body, nutrition, hydration, sleep, activity and habit data as a connected system.
Use only data that is present. Distinguish measured data, user-entered data, estimates and missing values.
Look for trends, relationships and changes over time when history is provided.
Do not diagnose disease or present a medical conclusion as certainty.
Do not invent measurements.
For potentially concerning measurements, explain the limitation and recommend appropriate professional care.
Give practical, personalized next actions and explain which data points led to them.
Avoid generic advice when the user's data supports a more specific answer.
"""


@app.get("/health")
def health():
    return {"status": "ok", "service": "sunya-ai", "providers": ["chatgpt", "gemini", "claude", "sunya"]}


def _prompt(request: ChatRequest) -> str:
    return f"""{SYSTEM_PROMPT}

USER HEALTH CONTEXT:
{request.context}

USER QUESTION:
{request.message}

Return a concise but substantive answer. Structure it as:
1. What the data indicates
2. What matters most now
3. Specific actions
4. What to track next
"""


async def _gemini(prompt: str) -> str:
    key = os.getenv("GEMINI_API_KEY", "").strip()
    if not key:
        raise RuntimeError("GEMINI_API_KEY is not configured")
    from google import genai
    client = genai.Client(api_key=key)
    response = await client.aio.models.generate_content(
        model=os.getenv("GEMINI_MODEL", "gemini-2.5-flash"),
        contents=prompt,
    )
    return response.text or "No response was generated."


async def _openai(prompt: str) -> str:
    key = os.getenv("OPENAI_API_KEY", "").strip()
    if not key:
        raise RuntimeError("OPENAI_API_KEY is not configured")
    model = os.getenv("OPENAI_MODEL", "gpt-5-mini")
    async with httpx.AsyncClient(timeout=60) as client:
        response = await client.post(
            "https://api.openai.com/v1/responses",
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            json={"model": model, "instructions": SYSTEM_PROMPT, "input": prompt},
        )
        response.raise_for_status()
        data = response.json()
        return data.get("output_text") or "No response was generated."


async def _claude(prompt: str) -> str:
    key = os.getenv("ANTHROPIC_API_KEY", "").strip()
    if not key:
        raise RuntimeError("ANTHROPIC_API_KEY is not configured")
    model = os.getenv("ANTHROPIC_MODEL", "claude-sonnet-4-5")
    async with httpx.AsyncClient(timeout=60) as client:
        response = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={
                "model": model,
                "max_tokens": 1400,
                "system": SYSTEM_PROMPT,
                "messages": [{"role": "user", "content": prompt}],
            },
        )
        response.raise_for_status()
        data = response.json()
        blocks = data.get("content", [])
        return "".join(block.get("text", "") for block in blocks if block.get("type") == "text") or "No response was generated."


@app.post("/v1/ai/chat")
async def chat(request: ChatRequest):
    prompt = _prompt(request)
    try:
        if request.provider in ("gemini", "sunya"):
            text = await _gemini(prompt)
        elif request.provider == "chatgpt":
            text = await _openai(prompt)
        else:
            text = await _claude(prompt)
        return {"provider": request.provider, "text": text}
    except httpx.HTTPStatusError as exc:
        raise HTTPException(status_code=502, detail=f"{request.provider} provider request failed") from exc
    except Exception as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
