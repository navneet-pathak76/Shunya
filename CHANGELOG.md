# Changelog

All notable changes to SUNYA will be documented here.

## Unreleased

### Backend core

- Added a persistent FastAPI + SQLAlchemy local API core under `backend/`.
- Added generic versioned records with UTC timestamps and soft-delete tombstones, providing a stable persistence boundary for body, hydration, sleep, nutrition, workouts, habits, goals and future domains.
- Added generic CRUD endpoints at `/v1/entries`, a daily `/v1/dashboard`, and `/v1/analytics/summary`.
- Added automated API coverage for health, CRUD, version increments, soft deletion and dashboard/summary aggregation.

### Architecture cleanup (duplicate elimination)

- Removed dead placeholder duplicate `apps/mobile/lib/app/app.dart` (root shell). Canonical root shell is `apps/mobile/lib/app/sunya_app.dart`, which is what `main.dart` actually wires up.
- Removed dead placeholder duplicate `apps/mobile/lib/core/router/app_router.dart`. Canonical router is `apps/mobile/lib/app/router/sunya_router.dart` (wired into `SunyaApp` via `MaterialApp.router`).
- Removed dead placeholder duplicate `apps/mobile/lib/core/storage/local_store.dart`. Canonical storage is `apps/mobile/lib/core/storage/sunya_storage.dart` (wired into `storageProvider` and consumed by feature controllers, e.g. `BodyController`, `HydrationController`).
- Removed dead placeholder duplicate `apps/mobile/lib/core/services/notification_service.dart` (single-line TODO stub). Canonical notification contract is `apps/mobile/lib/core/services/notifications/notification_service.dart` (`NotificationService` interface + `ReminderDefinition`). No concrete implementation of the interface exists yet — tracked as a known limitation.
- Migrated `BodyMeasurement`/`MeasurementType` and `HealthProfile`/`BiologicalSex`/`GoalDirection` from the orphaned top-level `apps/mobile/lib/models/` into the canonical feature-first location `apps/mobile/lib/features/body/domain/entities/`.
- Removed `apps/mobile/lib/models/daily_log.dart` and `apps/mobile/lib/shared/models/daily_state.dart`; cross-domain daily aggregation belongs to the analytics layer.
- Removed `apps/mobile/lib/repositories/health_repository.dart` and `apps/mobile/lib/repositories/repository_contracts.dart` because they were unused placeholders.
