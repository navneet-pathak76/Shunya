# SUNYA local database

SUNYA uses Isar as the local-first database for domain records. SharedPreferences remains available for lightweight app preferences only.

## Rules

- Do not open a second Isar instance from a feature.
- Access the database through `SunyaDatabase` / `sunyaDatabaseProvider`.
- Feature repositories should use `LocalRecordRepository` or a typed repository built on top of it.
- Store domain payloads as JSON at this generic boundary until each feature receives its typed Isar collection.
- Use UTC for persisted timestamps.
- Keep soft-delete/version semantics so cloud sync can be added later without changing the core persistence contract.

## Generated schema

When the model changes, regenerate with `dart run build_runner build --delete-conflicting-outputs`.
