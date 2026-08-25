# Security Policy

## Scope

Sky Ruby Scheduler calculates schedule metadata only. It does not execute commands, launch jobs, contact external services, store credentials, or provide a durable scheduling control plane.

## Supported boundary

Report issues involving validation bypass, unsafe parsing, denial-of-service conditions within documented bounds, unexpected code execution, container privilege regressions, or incorrect schedule advancement.

## Non-goals

This engineering-beta repository does not claim authentication, multi-tenant isolation, durable audit logging, leader election, distributed locking, secrets management, timezone/calendar semantics, or production deployment validation.

Do not include secrets or sensitive production data in vulnerability reports.
