# SUNYA Domain Map

SUNYA is organized around longitudinal personal data rather than isolated trackers. Every domain should produce timestamped records that can be correlated by the AI and reporting layers.

## Core domains

- **Identity & Profile:** identity, preferences, units, timezone, privacy settings.
- **Body:** height, weight, circumferences, body-fat estimates, muscle mass, photos and measurement history.
- **Goals:** desired outcomes, target values, deadlines, priorities and status.
- **Nutrition:** foods, meals, recipes, calories, macros, micros and meal plans.
- **Hydration:** water events, targets, schedules, reminders and adherence.
- **Movement:** workouts, exercises, sets, reps, load, cardio and progression.
- **Sleep & Recovery:** sleep windows, duration, quality, recovery indicators and notes.
- **Habits:** recurring behaviors, streaks, completion and adherence.
- **Smoking:** events, quantity, timing, triggers and reduction goals.
- **Alcohol:** events, quantity, timing, context and reduction goals.
- **Medication & Supplements:** schedules, adherence, notes and user-defined metadata.
- **Mood & Journal:** mood observations, free-form journal entries, tags and correlations.
- **Analytics:** trends, baselines, correlations, milestones and reports.
- **AI:** context assembly, retrieval, inference requests, responses, feedback and audit metadata.
- **Integrations:** Health Connect, wearables, camera, voice and future providers.
- **Backup & Export:** encrypted backup, import/export jobs and data portability.

## Cross-cutting requirements

All longitudinal records should have a stable identifier, created/updated timestamps, source, optional note, timezone-aware event time, and provenance where applicable. Sensitive records must have explicit retention/export behavior and must never be logged with secret credentials.

## Implementation rule

Domain models belong in the domain layer. Persistence details belong behind repositories. UI state must not directly access database or HTTP clients.
