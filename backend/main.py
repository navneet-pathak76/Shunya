import os
from typing import Any, Literal

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="SUNYA AI", version="2.0.0")


class ChatRequest(BaseModel):
    message: str
    provider: Literal["chatgpt", "gemini", "claude", "sunya"] = "sunya"
    context: dict[str, Any] = Field(default_factory=dict)


def _system_prompt(provider: str) -> str:
    base = """You are SUNYA, a personal health intelligence system.
Analyze the complete supplied user context before answering.
Balance the whole body rather than optimizing one metric in isolation.
Use measured/tracked data when available and clearly label estimates.
Never invent missing measurements.
Compare trends and interactions across activity, body composition, sleep, hydration, nutrition, vitals and user-entered observations when present.
Do not diagnose disease or present a medical conclusion as certainty.
For potentially concerning measurements, explain the limitation and recommend appropriate professional care.
Keep the response practical, structured and personalized."""
    if provider == "sunya":
        return base + """
You are the SUNYA layer, so synthesize the data into a coherent personal plan:
1. what the data says,
2. what appears balanced or out of balance,
3. the highest-impact actions,
4. what to track next,
5. any safety flags.
Do not reduce the answer to generic wellness advice."""
    return base


def _context_prompt(request: ChatRequest) -> str:
    return f"""USER HEALTH CONTEXT:
{request.context}

USER QUESTION:
{request.message}
"""


@app.get("/health")
def health():
    return {"status": "ok", "service": "sunya-ai"}


@app.get("/v1/ai/providers")
def providers():
    return {
        "providers": {
            "chatgpt": bool(os.getenv("OPENAI_API_KEY", "").strip()),
            "gemini": bool(os.getenv("GEMINI_API_KEY", "").strip()),
            "claude": bool(os.getenv("ANTHROPIC_API_KEY", "").strip()),
            "sunya": bool(os.getenv("GEMINI_API_KEY", "").strip()),
        }
    }


async def _gemini(prompt: str) -> str:
    api_key = os.getenv("GEMINI_API_KEY", "").strip()
    if not api_key:
        raise HTTPException(status_code=503, detail="Gemini provider is not configured")
    try:
        from google import genai

        client = genai.Client(api_key=api_key)
        response = await client.aio.models.generate_content(
            model=os.getenv("GEMINI_MODEL", "gemini-2.5-flash"),
            contents=prompt,
        )
        return response.text or "I could not generate an answer right now."
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=502, detail="Gemini provider request failed") from exc


async def _openai(prompt: str) -> str:
    api_key = os.getenv("OPENAI_API_KEY", "").strip()
    if not api_key:
        raise HTTPException(status_code=503, detail="ChatGPT provider is not configured")
    payload = {
        "model": os.getenv("OPENAI_MODEL", "gpt-5.5"),
        "input": prompt,
    }
    try:
        async with httpx.AsyncClient(timeout=90) as client:
            response = await client.post(
                "https://api.openai.com/v1/responses",
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json",
                },
                json=payload,
            )
        response.raise_for_status()
        data = response.json()
        output = data.get("output_text")
        if output:
            return output
        for item in data.get("output", []):
            for content in item.get("content", []):
                if content.get("type") == "output_text" and content.get("text"):
                    return content["text"]
        return "I could not generate an answer right now."
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=502, detail="ChatGPT provider request failed") from exc


async def _claude(prompt: str) -> str:
    api_key = os.getenv("ANTHROPIC_API_KEY", "").strip()
    if not api_key:
        raise HTTPException(status_code=503, detail="Claude provider is not configured")
    payload = {
        "model": os.getenv("ANTHROPIC_MODEL", "claude-sonnet-5-5"),
        "max_tokens": int(os.getenv("ANTHROPIC_MAX_TOKENS", "1800")),
        "system": _system_prompt("claude"),
        "messages": [{"role": "user", "content": prompt}],
    }
    try:
        async with httpx.AsyncClient(timeout=90) as client:
            response = await client.post(
                "https://api.anthropic.com/v1/messages",
                headers={
                    "x-api-key": api_key,
                    "anthropic-version": "2023-06-01",
                    "content-type": "application/json",
                },
                json=payload,
            )
        response.raise_for_status()
        data = response.json()
        for block in data.get("content", []):
            if block.get("type") == "text" and block.get("text"):
                return block["text"]
        return "I could not generate an answer right now."
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=502, detail="Claude provider request failed") from exc


@app.post("/v1/ai/chat")
async def chat(request: ChatRequest):
    prompt = _system_prompt(request.provider) + "\n\n" + _context_prompt(request)

    if request.provider in {"gemini", "sunya"}:
        text = await _gemini(prompt)
    elif request.provider == "chatgpt":
        text = await _openai(prompt)
    elif request.provider == "claude":
        text = await _claude(prompt)
    else:
        raise HTTPException(status_code=400, detail="Unsupported AI provider")

    return {
        "text": text,
        "provider": request.provider,
        "analysis": "whole_body_context",
    }
