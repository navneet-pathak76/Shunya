from __future__ import annotations

from contextlib import asynccontextmanager
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Any
from uuid import uuid4

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import Boolean, Date, DateTime, Float, Integer, String, Text, create_engine, select
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column, sessionmaker

DB_URL = "sqlite:///./sunya.db"
engine = create_engine(DB_URL, connect_args={"check_same_thread": False})
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


@asynccontextmanager
async def lifespan(_: FastAPI):
    Base.metadata.create_all(engine)
    yield


app = FastAPI(title="SUNYA API", version="0.2.0", lifespan=lifespan)


def serialize(row: Record) -> dict[str, Any]:
    import json
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


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "sunya-api"}


@app.post("/v1/entries", status_code=201)
def create_entry(entry: Entry) -> dict[str, Any]:
    import json
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
    import json
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
