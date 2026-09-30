from __future__ import annotations

import json
import os
from contextlib import asynccontextmanager
from datetime import date, datetime, timezone
from typing import Any
from uuid import uuid4

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import Boolean, Date, DateTime, Integer, String, Text, create_engine, select
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column, sessionmaker

DB_URL = os.getenv("SUNYA_DATABASE_URL", "sqlite:///./sunya.db")
engine = create_engine(DB_URL, connect_args={"check_same_thread": False} if DB_URL.startswith("sqlite") else {})
SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)


def now() -> datetime:
    return datetime.now(timezone.utc)


def uid() -> str:
    return str(uuid4())


class Base(DeclarativeBase):
    pass


class Record(Base):
    __tablename__ = "records"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uid)
    kind: Mapped[str] = mapped_column(String(40), index=True)
    payload: Mapped[str] = mapped_column(Text, default="{}")
    record_date: Mapped[date] = mapped_column(Date, default=date.today, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now, onupdate=now)
    version: Mapped[int] = mapped_column(Integer, default=1)
    deleted: Mapped[bool] = mapped_column(Boolean, default=False)


class Entry(BaseModel):
    kind: str = Field(min_length=1, max_length=40)
    data: dict[str, Any] = Field(default_factory=dict)
    record_date: date | None = None


class Patch(BaseModel):
    data: dict[str, Any] | None = None
    record_date: date | None = None


class AiChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=8000)
    context: dict[str, Any] = Field(default_factory=dict)


class AiPlanRequest(BaseModel):
    context: dict[str, Any] = Field(default_factory=dict)


class AiPlan(BaseModel):
    summary: str
    priority: str
    calories: int
    protein_g: int
    water_ml: int
    workout: str
    meals: list[str]
    actions: list[str]


@asynccontextmanager
async def lifespan(_: FastAPI):
    Base.metadata.create_all(engine)
    yield


app = FastAPI(title="SUNYA API", version="0.3.0", lifespan=lifespan)


def serialize(row: Record) -> dict[str, Any]:
    return {
        "id": row.id,
        "kind": row.kind,
        "data": json.loads(row.payload),
        "record_date": row.record_date.isoformat(),
        "created_at": row.created_at.isoformat(),
        "updated_at": row.updated_at.isoformat(),
        "version": row.version,
    }


def get_row(db: Session, record_id: str) -> Record:
    row = db.get(Record, record_id)
    if not row or row.deleted:
        raise HTTPException(404, "Record not found")
    return row


def gemini_client():
    key = os.getenv("GEMINI_API_KEY") or os.getenv("SUNYA_GEMINI_API_KEY")
    if not key:
        raise HTTPException(503, "Gemini is not configured on the server")
    from google import genai
    return genai.Client(api_key=key)


def gemini_model() -> str:
    return os.getenv("SUNYA_GEMINI_MODEL", "gemini-3.8-flash")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "sunya-api"}


@app.post("/v1/entries", status_code=201)
def create_entry(entry: Entry) -> dict[str, Any]:
    with SessionLocal() as db:
        row = Record(kind=entry.kind, payload=json.dumps(entry.data), record_date=entry.record_date or date.today())
        db.add(row)
        db.commit()
        db.refresh(row)
        return serialize(row)


@app.get("/v1/entries")
def list_entries(kind: str | None = None, target_date: date | None = Query(default=None)) -> list[dict[str, Any]]:
    with SessionLocal() as db:
        stmt = select(Record).where(Record.deleted.is_(False)).order_by(Record.record_date.desc(), Record.created_at.desc())
        if kind:
            stmt = stmt.where(Record.kind == kind)
        if target_date:
            stmt = stmt.where(Record.record_date == target_date)
        return [serialize(row) for row in db.scalars(stmt).all()]


@app.get("/v1/entries/{record_id}")
def read_entry(record_id: str) -> dict[str, Any]:
    with SessionLocal() as db:
        return serialize(get_row(db, record_id))


@app.patch("/v1/entries/{record_id}")
def update_entry(record_id: str, patch: Patch) -> dict[str, Any]:
    with SessionLocal() as db:
        row = get_row(db, record_id)
        if patch.data is not None:
            row.payload = json.dumps(patch.data)
        if patch.record_date is not None:
            row.record_date = patch.record_date
        row.version += 1
        db.commit()
        db.refresh(row)
        return serialize(row)


@app.delete("/v1/entries/{record_id}")
def delete_entry(record_id: str) -> dict[str, str]:
    with SessionLocal() as db:
        row = get_row(db, record_id)
        row.deleted = True
        row.version += 1
        db.commit()
        return {"status": "deleted", "id": record_id}


@app.get("/v1/dashboard")
def dashboard(target_date: date | None = Query(default=None)) -> dict[str, Any]:
    d = target_date or date.today()
    with SessionLocal() as db:
        rows = db.scalars(select(Record).where(Record.record_date == d, Record.deleted.is_(False))).all()
    groups: dict[str, list[dict[str, Any]]] = {}
    for row in rows:
        groups.setdefault(row.kind, []).append(serialize(row))
    return {"date": d.isoformat(), "counts": {k: len(v) for k, v in groups.items()}, "entries": groups}


@app.get("/v1/analytics/summary")
def analytics_summary(days: int = Query(default=7, ge=1, le=365)) -> dict[str, Any]:
    cutoff = date.today().toordinal() - days + 1
    with SessionLocal() as db:
        rows = db.scalars(select(Record).where(Record.deleted.is_(False))).all()
    recent = [r for r in rows if r.record_date.toordinal() >= cutoff]
    return {
        "days": days,
        "records": len(recent),
        "by_kind": {kind: sum(1 for r in recent if r.kind == kind) for kind in sorted({r.kind for r in recent})},
        "active_dates": len({r.record_date for r in recent}),
    }


@app.post("/v1/ai/chat")
def ai_chat(request: AiChatRequest) -> dict[str, str]:
    client = gemini_client()
    context = json.dumps(request.context, separators=(",", ":"), default=str)
    prompt = (
        "You are SUNYA, a personal health and lifestyle planning assistant. "
        "Use the supplied user context. Do not diagnose, prescribe medication, or claim medical certainty. "
        "Prefer concise actionable guidance and explicitly distinguish estimates from measured data.\n\n"
        "USER CONTEXT:\n" + context + "\n\nUSER MESSAGE:\n" + request.message
    )
    response = client.models.generate_content(model=gemini_model(), contents=prompt)
    return {"text": response.text or "I could not generate a response."}


@app.post("/v1/ai/plan", response_model=AiPlan)
def ai_plan(request: AiPlanRequest) -> AiPlan:
    client = gemini_client()
    context = json.dumps(request.context, separators=(",", ":"), default=str)
    prompt = (
        "Create a one-day SUNYA plan from this context. "
        "Do not diagnose or prescribe. Keep nutrition and hydration targets as estimates. "
        "Return practical meals, workout guidance and actions.\n\nCONTEXT:\n" + context
    )
    from google.genai import types
    response = client.models.generate_content(
        model=gemini_model(),
        contents=prompt,
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=AiPlan,
        ),
    )
    try:
        return AiPlan.model_validate(json.loads(response.text))
    except Exception as exc:
        raise HTTPException(502, "Gemini returned an invalid SUNYA plan") from exc
