---
name: cicd-pipeline
description: CI/CD pipeline design and implementation skill. Covers GitHub Actions, GitLab CI, and generic pipeline patterns. Reusable by ops-agent. Includes security gates, test stages, and deployment automation.
---

# CI/CD Pipeline — Shared Skill

## Standard Pipeline Stages
1. **lint** — code style, formatting
2. **type-check** — static type validation
3. **test:unit** — fast, isolated unit tests
4. **test:integration** — integration tests (may need services)
5. **security:scan** — dependency audit + SAST
6. **build** — compile/bundle artifacts
7. **test:e2e** — end-to-end smoke tests (staging)
8. **deploy:staging** — auto-deploy to staging on `dev` branch
9. **deploy:prod** — deploy to production on `main` (requires approval gate)

## GitHub Actions Template
```yaml
name: CI

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main, dev]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm test
      - run: npm audit --audit-level=high

  build:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build

  deploy-staging:
    needs: build
    if: github.ref == 'refs/heads/dev'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - run: echo "Deploy to staging"
```

## Security Gate Requirements
- Block merge if: critical CVE in dependencies, SAST finding (high+), secrets detected
- Never deploy with failing tests
- Require approval for production deployments

## NBR. Pipeline Principles
- Fast feedback: unit tests must run in < 2 minutes
- Fail fast: put cheap checks first (lint before build)
- Immutable artifacts: build once, promote across environments
- Secrets via environment variables or vault, never in pipeline YAML
