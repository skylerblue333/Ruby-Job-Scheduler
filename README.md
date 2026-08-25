# Sky Schedule Ruby

**Status: engineering beta.** This repository is a small Ruby 3.3 scheduling primitive for registering bounded interval jobs and calculating the next UTC run time deterministically.

It does **not** execute commands, persist jobs, run background workers, provide cron syntax, handle time zones beyond explicit timestamps, distribute work, retry failed work, provide HA, or prove production deployment.

## What it does

- registers up to 1,000 named interval schedules;
- validates IDs and intervals;
- calculates the first run strictly after a supplied UTC timestamp;
- returns deterministic snapshots sorted by job ID;
- exposes a CLI whose output explicitly reports `command_execution: false`;
- ships with Minitest coverage and a non-root container.

## Run

```bash
ruby bin/sky-schedule
ruby -Ilib:test test/test_sky_schedule.rb
```

## Container

```bash
docker build -t sky-schedule-ruby .
docker run --rm sky-schedule-ruby
```

## Integration boundary

SKYCOIN4444 can use this component as a pure schedule-calculation library. A production job system would need durable storage, an execution worker, authentication/authorization, audit logging, retries, observability, deployment evidence, and operational procedures around this primitive.

## Security

The library accepts schedule metadata only. It deliberately has no API for shell commands, arbitrary code, network callbacks, secrets, or credentials. Treat all timestamps and identifiers as untrusted input and validate them at the calling boundary as well.

## License

See `LICENSE`.
