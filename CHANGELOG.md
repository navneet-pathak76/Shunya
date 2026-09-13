# Changelog

All notable changes to SUNYA will be documented here.

## Unreleased

- Initial repository and architecture skeleton.
- No production feature logic implemented yet.

### Architecture cleanup (duplicate elimination)

- Removed dead placeholder duplicate `apps/mobile/lib/app/app.dart` (root shell). Canonical root shell is `apps/mobile/lib/app/sunya_app.dart`, which is what `main.dart` actually wires up.
- Removed dead placeholder duplicate `apps/mobile/lib/core/router/app_router.dart`. Canonical router is `apps/mobile/lib/app/router/sunya_router.dart` (wired into `SunyaApp` via `MaterialApp.router`).
- Removed dead placeholder duplicate `apps/mobile/lib/core/storage/local_store.dart`. Canonical storage is `apps/mobile/lib/core/storage/sunya_storage.dart` (wired into `storageProvider` and consumed by feature controllers, e.g. `BodyController`, `HydrationController`).
- Removed dead placeholder duplicate `apps/mobile/lib/core/services/notification_service.dart` (single-line TODO stub). Canonical notification contract is `apps/mobile/lib/core/services/notifications/notification_service.dart` (`NotificationService` interface + `ReminderDefinition`). No concrete implementation of the interface exists yet — tracked as a known limitation.
- Migrated `BodyMeasurement`/`MeasurementType` and `HealthProfile`/`BiologicalSex`/`GoalDirection` from the orphaned top-level `apps/mobile/lib/models/` into the canonical feature-first location `apps/mobile/lib/features/body/domain/entities/`. These types were unused (no controller, repository, or UI referenced them) but represent real domain concepts the Body feature will need (measurement history by type/unit, profile fields) — moved rather than deleted.
- Removed `apps/mobile/lib/models/daily_log.dart` and `apps/mobile/lib/shared/models/daily_state.dart`. Both were unreferenced anywhere in the app and represented a premature, single-file cross-domain "daily snapshot" model. This concept belongs to the Cross-Domain Analytics batch (aggregating real per-feature data), not to a standalone model with no producer or consumer — resurrecting the old shape would bake in an aggregation design that hasn't been decided yet.
- Removed `apps/mobile/lib/repositories/health_repository.dart` and `apps/mobile/lib/repositories/repository_contracts.dart`. `HealthRepository` only referenced the now-migrated/removed top-level models and had no implementation or caller. `repository_contracts.dart` was an empty placeholder. The project's actual repository pattern lives per-feature (see `features/workout/data/workout_repository.dart`) — a `BodyRepository` should be added under `features/body/data/` when Body persistence is implemented (see Known limitations).
