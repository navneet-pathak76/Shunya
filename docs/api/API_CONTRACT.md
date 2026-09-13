# SUNYA API Contract

The backend is an optional synchronization and intelligence boundary. The mobile application remains usable offline.

## Implemented core

- `GET /health` — service health check.
- `POST /v1/entries` — create a typed domain record.
- `GET /v1/entries?kind=&target_date=` — list records with optional domain/date filters.
- `GET /v1/entries/{id}` — retrieve one record.
- `PATCH /v1/entries/{id}` — update record data/date and increment its version.
- `DELETE /v1/entries/{id}` — soft-delete a record.
- `GET /v1/dashboard?target_date=` — aggregate the day's records by domain.
- `GET /v1/analytics/summary?days=` — basic cross-domain activity summary.

Each persisted record carries `id`, `created_at`, `updated_at`, `version`, `record_date`, and a soft-delete flag. The generic record payload is intentionally domain-agnostic so the mobile app can remain local-first while the backend contract evolves.

## Domain kinds supported by the core boundary

`body`, `hydration`, `sleep`, `habits`, `goals`, `nutrition`, `workout`, and future SUNYA domains can be represented without changing the storage schema.

## Still pending

- Dedicated domain-specific schemas and endpoints for body, hydration, nutrition, workouts, sleep, habits and goals.
- Cross-domain trend/correlation engine beyond basic activity aggregation.
- Authentication and account isolation.
- Sync/conflict-resolution protocol using `version` and tombstones.
- PostgreSQL deployment verification.
- AI context builder and AI service boundary.
- Health Connect/wearables integrations.
- Backup/export/restore.

No endpoint should expose more personal data than required for the operation.
