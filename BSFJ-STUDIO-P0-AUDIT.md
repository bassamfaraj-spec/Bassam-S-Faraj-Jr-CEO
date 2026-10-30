# BSFJ Studio P0 audit

Captured: 2026-10-01
Source workspace audited: `/Users/bassamfaraj/BSFJ-Studio.worktrees/launch-new-products-banking-integration`

## Scope

This audit covers APP-01 P0 tasks carried from Studio:

- P0.1 Feature and launch-blocker audit
- P0.2 Workflow QA checkpoints
- P0.3 Operating-cost and revenue-path worksheet scaffold

## P0.1 Feature inventory and launch blockers

### Confirmed implemented now

- Project registry with status/priority tracking
- Agent registry (role records)
- Task lists and approval queue
- Demo finance dashboard
- Payout approval gate with explicit safeguards
- Optional Plaid read-only connection flow with safety locks
- Distribution checklist tracking for manual submissions

### External-launch blockers (ordered)

| Priority | Blocker | Why this blocks launch | Evidence |
|---|---|---|---|
| P0 | No execution engine for tasks | Agent rows are static role definitions; no worker runtime or automation dispatch exists. | `app/seed.py`, `app/main.py` |
| P0 | No social publishing/messaging integration | Brand and OH-01 workflows cannot publish or outreach from Studio. | `README.md`, `app/main.py` routes |
| P0 | No consented contact pipeline | There is no approved recipient/contact model for one-to-one outreach. | `app/db.py` schema (no contacts table) |
| P0 | No authenticated multi-user control plane | Approvals rely on local operator context, not role-based auth for delegated operations. | `app/main.py`, `app/templates/approvals.html` |
| P1 | Local-first deployment posture | Current run path is local Flask + SQLite; no production runbook in repo. | `README.md`, `run.sh` |
| P1 | Banking and payouts intentionally gated | Real banking/payout actions are correctly restricted, so "auto launch" cannot occur by design. | `app/banking.py`, `app/payments.py` |
| P1 | No recruiting workflow backend | OH-01 talent interest is draft content only; no intake form pipeline for external applicants. | `data/studio.db` task/content state |
| P2 | No analytics funnel instrumentation | No measurable external campaign telemetry path is defined yet. | `app/main.py`, templates |

## P0.2 QA workflow checkpoints

These checks should pass before any production-connectivity work:

1. Dashboard/agents/approvals/finance/banking/intake pages return HTTP 200.
2. Approval state changes persist and reflect in queue ordering.
3. Payout gate enforces release approval before payout approval.
4. `send-real` path remains blocked unless all safety conditions are met.
5. Banking link token and exchange endpoints fail safely when not configured.
6. Intake scan/suggest/curate keeps unknown files unreviewed (no unsafe auto-linking).
7. Distribution status updates are idempotent per `(project, platform)`.
8. New carryover projects/tasks remain readable in project detail pages.

## P0.3 Operating-cost and revenue-path worksheet scaffold

### Cost buckets to fill

| Bucket | Example line items | Status |
|---|---|---|
| Hosting/runtime | app hosting, backups, domain, TLS | Missing owner inputs |
| Data/security | logging retention, key management, incident tooling | Missing owner inputs |
| Integrations | social APIs, distribution tooling, messaging provider | Missing owner inputs |
| Legal/compliance | counsel review, policy drafting, filing costs | Missing owner inputs |
| Creative production | music, design, video, editing contractors | Missing owner inputs |
| Operations | PM/admin support, QA cadence | Missing owner inputs |

### Revenue-path assumptions to validate

| Track | Preconditions | Current readiness |
|---|---|---|
| Music releases | Final audio, rights metadata, distributor accounts | Draft only |
| Brand collaborations | Approved outreach process, consented contacts, offer templates | Draft only |
| Software tools/services | Defined offer, billing, support process | Not defined |
| Invention licensing | Prior-art evidence, disclosure strategy, counsel review | Early concept |
| TV/story IP deals | Script package, pitch assets, representation strategy | Early development |

## Immediate next execution order

1. Implement authenticated operator model for approvals and payout controls.
2. Add explicit contacts + consent data model and review workflow.
3. Add social/distribution integration adapters behind owner approval gates.
4. Add OH-01 expression-of-interest intake flow with privacy notice and consent logging.
5. Add production deployment runbook and environment hardening checklist.
