# SUNYA Stack Decision

## Primary application
Flutter + Dart. The mobile app is the primary product and is the only application stack required for the first implementation phase.

## State and navigation
- Riverpod
- GoRouter

## Local-first data
- Isar for structured local application data
- flutter_secure_storage for secrets/credentials

## Backend
Python + FastAPI is reserved for synchronization, AI orchestration, account-independent services, and future remote processing.

## Server database
PostgreSQL is the planned server-side relational database when cloud synchronization is introduced.

## Web
TypeScript is reserved for a future web dashboard. It is not part of the first mobile MVP.

## Deployment
- Railway: backend/API/database services where appropriate
- Vercel: future web frontend

## Important boundary
This repository is currently an architecture skeleton. Do not introduce feature implementation until the corresponding product, data, API, privacy, and UX contracts are approved.