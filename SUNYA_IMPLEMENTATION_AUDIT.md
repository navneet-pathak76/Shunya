# SUNYA Implementation Audit

## Executive summary

This repository is currently an early architecture skeleton, not a production-ready application. The mobile app contains a few real state-management flows and a generic local persistence boundary, but the implementation remains incomplete, fragmented, and partially broken.

The repository is best described as Phase 0 / Phase 1 skeleton work with a few domain proof points, not a finished product. Several core requirements from the product brief are still missing, and the actual analyzer status confirms the codebase is not yet in a releasable state.

Evidence from the current repo:

- README explicitly states: "Current phase: Architecture / Skeleton only."
- The app has a router, a dark theme, a few feature pages, and a generic Isar storage boundary.
- The backend is a minimal FastAPI service with generic record endpoints and a smoke test.
- Flutter analyzer currently reports errors in storage and database usage.
- The UI uses placeholder state and hard-coded zero/placeholder values in dashboard modules.

---

## A. Current architecture

### High-level structure

- Root repo contains product docs, architecture docs, deployment docs, and a backend service skeleton.
- `apps/mobile` contains the Flutter app.
- `backend` contains the FastAPI app and tests.
- `docs` contains product, UX, database, AI, and deployment contracts.
- `packages` is reserved for future shared design or model packages.

### Mobile app architecture

The current mobile architecture is intentionally simple but inconsistent:

- `main.dart` boots a `ProviderScope` and `SunyaApp`.
- `app/sunya_app.dart` configures a `MaterialApp.router` using `GoRouter`.
- `app/router/sunya_router.dart` defines routes for dashboard, body, nutrition, hydration, workout, sleep, habits, profile, and AI placeholders.
- `core/providers` contains providers for database and storage.
- `core/theme/sunya_theme.dart` defines the dark theme and some design tokens.
- `core/widgets` includes a few shared widgets such as `SunyaMetricCard` and `SunyaModulePage`.
- Feature folders exist under `features/*/presentation` with page/controller pairs for body, hydration, nutrition, workout, sleep, and habits.

### Data architecture

There are two local persistence patterns in active use:

1. `core/storage/sunya_storage.dart`
   - Wraps `SharedPreferences`.
   - Used by feature controllers such as `HydrationController`, `BodyController`, and `NutritionController`.
   - Good for lightweight preferences, but not ideal for structured domain entities.

2. `database/local_record_repository.dart` and `database/sunya_record.dart`
   - Implements a more structured Isar-based generic record store.
   - Designed for app-wide local persistence of domain records.
   - This is the intended long-term architecture for app data.

This creates an architectural conflict: the app currently mixes `SharedPreferences` persistence for domain state and a generic Isar repository for some app records. The product brief explicitly requires one source of truth per domain and a consistent local-first persistence model.

### Domain model status

The app has some partial domain models but not full domain layer implementations:

- `features/workout/domain/entities/workout_session.dart` contains a workout domain entity with sets.
- `features/workout/data/workout_repository.dart` implements an in-memory repository, which is not persistent.
- Hydration, body, and nutrition state classes are simple DTO-like objects, not typed domain entities with validation or repository boundaries.

### Backend architecture

The backend is also a minimal skeleton:

- `backend/app/main.py` defines a generic `Record` entity with a `kind` field and JSON payload.
- FastAPI exposes generic CRUD endpoints under `/v1/entries` and `/v1/dashboard` and `/v1/analytics/summary`.
- This is better than an empty backend, but it remains a broad event-store pattern rather than domain-specific models.
- It does not yet model hydration, workouts, sleep, goals, and AI as structured domain APIs.

### Architectural alignment with the brief

The current repo aligns partially with the intended design:

- Local-first local persistence exists.
- Riverpod is present.
- Routing is present.
- Dark-first theme exists.
- Core domain folders exist.

However, it does not yet align with the brief’s required architecture:

- no fully typed domain repositories for all core domains
- no validation layer for form/domain inputs
- no analytics engine on real tracked data
- no responsive shell beyond a basic router
- no full design system tokens
- no proper local database patterns across all features
- no backend domain structure beyond generic records

---

## B. Existing working features

The following features are present and function at a basic level, but all are limited and incomplete.

### 1. Generic local storage boundary

`apps/mobile/lib/database/database.dart` and `apps/mobile/lib/database/sunya_record.dart` define a centralized Isar-backed record store.

What works:

- generic `SunyaRecord` model with `domain`, `key`, `payload`, timestamps, version, and soft-delete state
- app-level database lifecycle is centralized
- record payloads can be serialized as JSON for future domain-specific use

### 2. Hydration tracking

`HydrationController` and `HydrationPage` provide a basic daily hydration flow.

What works:

- target and consumed amount state
- quick add buttons
- reset today
- persisted via `SharedPreferences`
- dashboard reads from the same provider

Limitations:

- not stored as a proper domain entity or repository
- no history, trends, custom amount form, or date awareness
- no validation beyond integer parsing

### 3. Body tracking

`BodyController` and `BodyPage` support editable weight, height, and body fat values.

What works:

- weight, height, body fat save/load logic
- BMI calculation
- simple form dialog
- persistence in local storage

Limitations:

- no history, measurement timeline, or charting
- values are not backed by a repository or typed model
- no validation, units, or error handling
- no date-based measurement storage

### 4. Nutrition tracking

`NutritionController` and `NutritionPage` add meal entries with calories and protein.

What works:

- meal creation via dialog
- daily summary totals
- meal removal
- persistence via `SharedPreferences`

Limitations:

- no food database, meal editing, or different meal types beyond a string field
- no carbohydrates/fats models
- no persistent domain repository
- no date-based meal history

### 5. Workout session scaffolding

`features/workout/domain/entities/workout_session.dart` and the repository/controller define a basic workout session model.

What works:

- `WorkoutSession` and `WorkoutSet` entities exist
- sets can be tracked with reps and weight
- session volume and duration calculations exist
- controller can create or finish an in-progress session

Limitations:

- repository is in-memory only
- no persistent storage via Isar or local repo
- no exercise library, screen UI, or session history beyond a simple list state

### 6. Dashboard shell

`DashboardPage` is present and functionally navigates to modules.

What works:

- greeting/header layout
- hydration metric card
- navigation to body/nutrition/hydration/workout/sleep/habits
- AI card placeholder

Limitations:

- calories, sleep, workouts are hard-coded placeholder values
- no real data integration
- not responsive beyond a simple list/grid

### 7. Backend generic record API

`backend/app/main.py` provides a minimal generic CRUD and summary API.

What works:

- health endpoint
- create/list/read/update/delete entries
- soft delete semantics
- dashboard and analytics summary endpoints
- backend tests pass for the implemented endpoints

Limitations:

- generic kind-based storage is not yet domain-specific
- no user, auth, or sync layers
- no structured API for hydration, nutrition, workouts, or goals

---

## C. Broken features

The repository contains actual breakages that must be fixed before any production claim is credible.

### Flutter analyzer errors

The current command run on the mobile app is:

```bash
cd /Users/navneetpathak/Desktop/Shunya/apps/mobile && flutter analyze
```

It currently reports errors including:

- `lib/database/local_record_repository.dart` uses `findAll()` on an Isar `QueryBuilder`, which is invalid for the current Isar API
- generated file warnings and errors in `lib/database/sunya_record.g.dart`
- state notifier access violation in `body_page.dart` through `controller.state`
- broken widget test referencing `MyApp` that does not exist
- missing assets directory for `assets/` declared in `pubspec.yaml`

This means the project is not currently analyzer-clean and cannot be considered stable.

### Data architecture issues

- `HydrationController` uses `SharedPreferences` directly.
- `BodyController` uses `SharedPreferences` directly.
- `NutritionController` uses `SharedPreferences` directly.
- `WorkoutController` depends on a non-persistent in-memory repository.
- This is a mixed architecture and breaks the requirement for a single source of truth and local persistence consistency.

### UI defects and dead placeholders

- Many screens are wrappers around `SunyaModulePage` with hard-coded metrics and placeholder values.
- Module pages like `SleepPage`, `WorkoutPage`, and `HabitsPage` show `—`, `0`, and placeholder values rather than real or empty-state logic.
- `profile` and `ai` routes are just generic “under active development” placeholders.

---

## D. Duplicate implementations

The repository has multiple overlapping patterns that should be consolidated.

### 1. Duplicate persistence layers

- `SharedPreferences`-based app state in feature controllers
- generic Isar record repository in `database/`

These are competing persistence implementations for the same domains.

### 2. Duplicate module naming patterns

- `features/workout` and `features/workouts` both exist.
- Some of the product docs talk about body, weight, measurements, and body composition as separate domains, but the app skeleton does not embed a clear final architecture for them.

### 3. Duplicate shell concepts

The repo contains multiple general shell/doc artifacts and placeholder module docs. This indicates partial cleanup but not a single final canonical architecture.

### 4. Duplicate data concepts in docs and app code

The docs define a future product architecture with many domains, but the app has only isolated state and placeholder pages. This is a planned architecture, not a unified implementation.

---

## E. Missing features

The repository is missing large parts of the actual product brief.

### Core product areas not implemented

- Body measurement history and trend charts
- Hydration history and weekly trends
- Nutrition timeline with meal types, macros, and weekly analytics
- Workout logging with exercises / sets / reps / weight / volume / duration
- Sleep entry tracking and quality analytics
- Habit creation, editing, archiving, streaks, completion logic
- Goals creation and progress tracking
- Analytics with multiple time windows and charting
- AI architecture grounded in real SUNYA data
- Search architecture
- Reminders and notifications
- Settings/profile architecture
- Local-first sync and conflict handling
- Web/Safari-specific responsive shell and platform abstraction

### Missing infrastructure for the brief

- typed domain repositories for each major feature
- validation layer on forms and state transitions
- loading, empty, and error states across each feature
- feature-specific analytics reporting
- local database migrations
- proper feature-first architecture with domain use cases and repositories

---

## F. Technical debt

### 1. Incomplete architecture cleanup

The repo contains a lot of planned docs but not enough executed product architecture. The result is a skeleton with a few working pieces but no final shape.

### 2. Mixed persistence patterns

The same domain state is written in different ways across different files. This breaks the expectation of a single source of truth.

### 3. Placeholder-heavy UI

The app heavily uses generic cards and placeholder labels (`under active development`, `0`, `—`) instead of real empty states or real user-data views.

### 4. No data validation layer

Fields are parsed directly from Strings without domain validation, unit constraints, or user-friendly error states.

### 5. Incomplete generated code / stale tooling state

`generated` Isar code exists, but the current API usage is mismatched with the generated result. The repo needs a clean generate-analyze cycle before continuing.

---

## G. UI/UX problems

### Current UI issues

- The dashboard is not yet a premium “today overview”; it is a module grid with placeholder metrics.
- Several screens reuse generic `SunyaModulePage` cards, but this creates a template appearance rather than intentional product design.
- The design system exists only partially in `SunyaTheme`; there is no final design token library covering color roles, spacing, radii, typography, motion, and glass surfaces across all widgets.
- The app does not yet implement the rich hierarchy the brief calls for: section → important metric → supporting info → action.
- Many screens show zeros or em dashes instead of meaningful empty states or “No data yet” messaging.

### UX mismatch with product brief

The app does not currently feel like a premium personal operating system. It feels like a scaffolded utility app with a dark theme and modules rather than a data-driven lifestyle system.

---

## H. Database problems

The database layer is not yet aligned to the product brief.

### Problems

- Feature-level persistence is split between `SharedPreferences` and Isar, creating multiple sources of truth.
- `LocalRecordRepository` is generic but not yet used by the major domains.
- `SunyaRecord` is useful as a generic persistence boundary but does not cover typed entity schema for body, hydration, nutrition, workout, sleep, habits, and goals.
- No migrations or versioned schema management are defined beyond the generated Isar metadata.
- No domain-specific indexes or lifecycle policy are defined.
- No local timezone vs UTC design pattern is enforced consistently.
- Soft-delete semantics exist but not domain-level lifecycle logic.

### Risk

This will become difficult to evolve as more features are added, especially because the app needs local-first persistence while also preparing for optional remote sync.

---

## I. Web compatibility problems

The repo does not yet provide a credible web/Safari-compliant implementation.

### Issues

- The Flutter app is not yet responsive beyond a single-column mobile shell.
- No breakpoints or desktop layout strategy exist.
- The app uses platform-sensitive assumptions in several places without proper abstraction.
- Notifications, camera, permissions, and secure storage are not yet wrapped behind clean platform boundaries.
- `Isar` web compatibility and secure storage behavior need explicit verification.
- The project does not yet have a responsive web experience that fits the brief’s large-screen requirements.

---

## J. Testing gaps

### Current tests

The repo has only a small backend test suite:

- `backend/tests/test_api_core.py`

This covers health checks and generic entry API behavior, but not the core product flows.

### Missing tests

- app-level unit tests for body, hydration, nutrition, workout, goals, and habit domain calculations
- repository tests for Isar and in-memory persistence
- widget tests for dashboard, forms, empty states, and navigation
- integration tests for data persistence across app restart
- analytics tests for real metrics and trend logic
- regression tests for web-specific navigation and responsive layout behavior

### Actual existing breakage

There is a `test/widget_test.dart` file that currently fails because it references `MyApp`, which is not present. This indicates the test suite has not been kept in sync with the app.

---

## K. Recommended implementation order

The correct order should follow the product brief and the existing architecture, but it must also address current breakages first.

### Phase 1 — Stabilize the foundation

1. Fix Flutter analyzer errors.
2. Clean up Isar usage and generated files.
3. Remove or consolidate duplicate persistence patterns.
4. Finalize the design tokens and responsive shell.
5. Establish a consistent app-level navigation shell and empty/loading/error patterns.

### Phase 2 — Local database and repositories

1. Define typed domain entities for body, hydration, nutrition, workouts, sleep, habits, and goals.
2. Replace direct `SharedPreferences` use for these domains with repository-backed persistence.
3. Centralize Isar access via repository abstraction.
4. Define validation and transformation logic at the domain layer.

### Phase 3 — Core feature implementation

1. Body tracking
2. Hydration tracking
3. Nutrition tracking
4. Workout tracking
5. Sleep tracking
6. Habits
7. Goals

### Phase 4 — Dashboard integration

1. Replace placeholder dashboard values with real domain providers.
2. Implement daily overview metrics and empty states.
3. Keep all dashboard values derived from repository-backed state, not duplicated local variables.

### Phase 5 — Analytics

1. Implement 7/30/90/365 day periods.
2. Create summary calculations from real tracked entries.
3. Add charts with labels and empty states.

### Phase 6 — Notifications and reminders

1. Local notification abstraction
2. User-configurable reminder settings
3. Domain-specific reminder schedule logic

### Phase 7 — AI architecture

1. Build provider abstraction
2. Ground outputs in tracked data
3. Add secure backend handoff and data provenance

### Phase 8 — Search, backend hardening, sync architecture

1. Full domain search index
2. Domain-specific backend schemas
3. Optional remote sync and conflict handling

### Phase 9 — Web/Safari and release quality

1. Responsive web layout
2. Safari compatibility checks
3. Accessibility improvements
4. Performance tuning
5. Final test and build verification

---

## Final assessment

SUNYA is not production-ready today. It is a well-documented architecture skeleton with a few useful building blocks, but it lacks the typed repository architecture, stable persistence model, feature completeness, and quality controls demanded by the product brief and acceptance criteria.

The immediate next step is not a broad product redesign. The immediate next step is to repair the underlying architecture and stabilize the local-first domain foundation before adding major feature work.
