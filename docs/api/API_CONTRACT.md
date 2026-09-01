# SUNYA API Contract

The backend API is a future synchronization and intelligence boundary. The mobile application remains usable without it.

## Health

`GET /health` — service health check.

## Planned resource groups

- `/v1/profile`
- `/v1/body`
- `/v1/goals`
- `/v1/nutrition`
- `/v1/hydration`
- `/v1/workouts`
- `/v1/sleep`
- `/v1/habits`
- `/v1/smoking`
- `/v1/alcohol`
- `/v1/medications`
- `/v1/supplements`
- `/v1/mood`
- `/v1/journal`
- `/v1/reports`
- `/v1/ai`
- `/v1/integrations`
- `/v1/backup`

Exact request/response schemas will be defined before production implementation. No endpoint should expose more personal data than required for the operation.
