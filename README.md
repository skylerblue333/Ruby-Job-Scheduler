# Sky Ruby Scheduler

**Status: engineering beta.**

Sky Ruby Scheduler is a dependency-light Ruby scheduling primitive for registering bounded interval jobs, checking which jobs are due, calculating the next due time, and producing stable machine-readable schedule metadata.

It deliberately **does not execute commands or jobs**. The CLI reports `execution_performed: false`. This repository does not claim to be a distributed scheduler, cron daemon, workflow engine, durable queue, HA control plane, timezone-aware calendar scheduler, or verified production deployment.

## Capabilities

- Ruby 3.3 / standard library only at runtime
- validated job identifiers
- bounded registry capacity
- intervals from 1 second through 365 days
- deterministic due-job ordering
- next-run advancement that skips missed intervals
- stable JSON CLI output
- Minitest lifecycle and validation coverage
- syntax/test/container CI gates
- non-root runtime container

## Usage

```bash
ruby -Ilib:test test/test_scheduler.rb
ruby bin/sky-scheduler
```

Optional CLI environment variables:

```bash
SKY_SCHEDULER_JOB_ID=analytics.refresh \
SKY_SCHEDULER_INTERVAL_SECONDS=300 \
SKY_SCHEDULER_START_AT=2026-08-24T00:00:00Z \
ruby bin/sky-scheduler
```

Example response:

```json
{
  "status": "ok",
  "execution_performed": false,
  "scheduler_scope": "in_process_schedule_calculation",
  "job": {
    "id": "analytics.refresh",
    "interval_seconds": 300,
    "next_run_at": "2026-08-24T00:00:00Z"
  }
}
```

## Library contract

`SkyScheduler::Registry` supports `register`, `fetch`, `remove`, `due`, `advance`, `size`, and `snapshot`. All state is process-local and in-memory.

## SKYCOIN4444 integration

A consumer can use this library to calculate deterministic due times for internal maintenance or background-work metadata. Actual execution should be delegated to a separately authenticated and durable worker/queue boundary.

## Security and reliability boundaries

The scheduler never accepts shell commands and never executes caller-controlled code. It is intentionally dependency-light. Persistence, distributed locking, leader election, retries, calendars/timezones, authentication, audit-log durability, and execution isolation are outside this repository's verified scope.

See `SECURITY.md` for reporting and supported boundaries.
