---
name: logging-observability
description: Logging, monitoring, and observability setup skill. Covers structured logging, metrics, alerting, and distributed tracing patterns. Reusable by ops-agent and dev-agent.
---

# Logging + Observability — Shared Skill

## Structured Logging Standards
```json
{
  "timestamp": "ISO-8601",
  "level": "info|warn|error|debug",
  "service": "<service-name>",
  "trace_id": "<correlation-id>",
  "event": "<machine-readable event name>",
  "message": "<human-readable description>",
  "data": {}
}
```

**Rules:**
- Never log PII, credentials, or secrets
- Always include trace/correlation ID for distributed systems
- Use structured (JSON) logging in production; pretty-print only in dev
- Error logs must include: error type, message, stack trace, context
- Never expose internal stack traces to external callers

## Log Levels
| Level | Use |
|-------|-----|
| ERROR | System failure requiring immediate action |
| WARN | Unexpected but recoverable; investigate |
| INFO | Normal operational events (request in/out, startup) |
| DEBUG | Diagnostic detail; disable in production |

## Metrics (RED Method)
- **Rate** — requests per second
- **Errors** — error rate percentage
- **Duration** — latency percentiles (p50, p95, p99)

## Alerting Thresholds (Starting Points)
- Error rate > 1% → page
- p99 latency > 2s → warn; > 5s → page
- Service restart > 3 in 5m → page

## Health Check Pattern
```
GET /health
→ { status: "ok", uptime: <seconds>, version: "<semver>" }
```

## Distributed Tracing
- Propagate `X-Trace-Id` header across service calls
- Emit start/end spans for all external calls (DB, HTTP, queue)
- Tag spans with: service, operation, result, duration
