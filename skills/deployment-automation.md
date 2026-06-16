---
name: deployment-automation
description: Deployment automation skill covering release strategies, rollback procedures, environment promotion, and zero-downtime deployment patterns. Reusable by ops-agent.
---

# Deployment Automation — Shared Skill

## Deployment Strategies

### Blue/Green
- Two identical environments; switch traffic atomically
- Zero downtime; instant rollback by switching back
- Use when: stateless services, fast startup time

### Rolling
- Replace instances incrementally (e.g., 25% at a time)
- Reduces risk vs. big-bang; slower rollback
- Use when: stateful services, large fleets

### Canary
- Route small % of traffic to new version first
- Observe metrics before full rollout
- Use when: high-risk changes, large user bases

## Pre-Deployment Checklist
- [ ] All tests passing in CI
- [ ] Security scan clean (no critical/high CVEs)
- [ ] Staging validation complete
- [ ] Database migrations tested (if applicable)
- [ ] Rollback procedure defined and tested
- [ ] Monitoring/alerting active
- [ ] On-call notified for high-risk deploys

## Environment Promotion
```
dev branch → staging env (auto, on merge)
main branch → production (manual approval gate)
```

## Rollback Procedure
1. Identify failure signal (error rate spike, health check fail)
2. Execute rollback: restore previous artifact / flip traffic / revert migration
3. Verify rollback: confirm metrics return to baseline
4. Post-incident: document in incident log

## NBR. Deployment Rules
- Never deploy to production on Fridays or before long weekends
- Always have a tested rollback ready before deploying
- Deployment window: prefer low-traffic periods
- Tag every production release: `git tag -a v<semver> -m "<release notes>"`
- Production deploys require 2-person approval for critical systems
