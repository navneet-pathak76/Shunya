# SUNYA

**Personal Human Operating System**

SUNYA is a private, mobile-first personal platform designed to unify body data, nutrition, hydration, movement, sleep, habits, lifestyle, goals, and AI-assisted insights in one system.

> **Current phase: Architecture / Skeleton only.**
>
> This repository intentionally contains contracts, placeholders, documentation, and boundaries rather than production feature logic.

## Product pillars

- Body & measurements
- Nutrition & meals
- Hydration
- Training & movement
- Sleep & recovery
- Habits & routines
- Smoking & alcohol tracking
- Medication & supplements
- Goals & progress
- Journal & mood
- AI personal intelligence
- Reports & analytics
- Health/device integrations
- Privacy, security, backup & export

## Technical direction

| Layer | Technology | Role |
|---|---|---|
| Mobile | Flutter / Dart | Primary application |
| State | Riverpod | Application state and dependency management |
| Routing | GoRouter | Navigation |
| Local data | Isar | Offline-first personal data |
| API | Python / FastAPI | Future backend |
| Server DB | PostgreSQL | Future synchronization/backend |
| Web | TypeScript | Future dashboard |
| CI/CD | GitHub Actions | Automation |
| Backend hosting | Railway | Planned |
| Web hosting | Vercel | Planned |

## Repository map

- `apps/mobile` — Flutter application skeleton
- `apps/web` — future web/dashboard skeleton
- `backend` — FastAPI service skeleton
- `packages` — shared contracts, design system and utilities
- `docs` — product, architecture, data, AI, health, security and deployment specifications
- `infrastructure` — deployment and environment skeletons
- `scripts` — development and setup automation placeholders
- `.github` — CI/CD and contribution templates

## Principles

1. **Private by default.**
2. **Offline-first where practical.**
3. **Data ownership and exportability.**
4. **Explicit consent for device and health data.**
5. **AI is advisory and must not be presented as a diagnosis or medical treatment system.**
6. **No secrets in Git.**
7. **Feature-first architecture with clear domain boundaries.**

## Status

Phase 0 — repository and architecture skeleton.

See `docs/ROADMAP.md` for the planned implementation sequence.
