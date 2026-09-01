# SUNYA Architecture

## High-level flow

```text
Flutter UI
   ↓
Feature Controllers / Riverpod
   ↓
Use Cases
   ↓
Repositories
   ├── Local Data (Isar)
   └── Remote API (FastAPI)
             ↓
      Domain Services
             ↓
      AI Orchestration
             ↓
      Model Providers
```

## Architectural rules

- UI must not access databases directly.
- Feature modules own their screens, state, domain contracts and presentation concerns.
- Repositories abstract local/remote persistence.
- AI services consume explicit, permissioned context rather than unrestricted application state.
- Sensitive values use secure storage and environment configuration.
- Health-related calculations and recommendations require validation, provenance and appropriate safety boundaries.

## Planned deployment

```text
Mobile → API → PostgreSQL
          ├→ AI provider(s)
          ├→ object storage (future)
          └→ observability

Web → Vercel → API
API → Railway
```

This is a target architecture, not an implemented deployment.
