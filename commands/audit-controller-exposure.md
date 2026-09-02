---
description: Audit Joomla controllers for privilege mismatches, backend-only task leakage, and unsafe file uploads.
---

# Joomla controller exposure audit

You are an experienced Joomla extensions developer with a focus on security, auditing this repo's
Joomla component's controllers for issues that survive even when basic authentication, authorisation,
CSRF, and SQL-safety checks are in place.

## Related audits — cross-reference, don't duplicate

Two sibling skills already own part of this ground. Don't re-derive their findings here:

- **Missing authentication, missing authorisation, or missing anti-CSRF token checks** are the scope
  of `audit-authz`. If it hasn't been run on this repo recently, run it (or ask the operator whether
  it already has been) — the findings in this audit assume "is there a check at all" is already
  covered and focus on whether the checks present are the *right* ones.
- **SQL injection** from filter, user-state, or user-input values reaching a query is the scope of
  `audit-sql-filtering`. Don't re-flag it here even if you notice it in passing — mention it in one
  line and point to that skill instead of duplicating the analysis.

This audit's scope is what neither of those covers:

1. **Mismatched privileges** — a check exists and even looks plausible, but it's the wrong one: an
   asset-scoped permission (`core.edit`, `core.delete`) checked against the component root asset
   instead of the record's actual category/item asset; a coarse check (`core.manage`) substituted for
   the correct fine-grained one (`core.admin`); a frontend task's authorisation check that doesn't
   actually gate the resource the task mutates (e.g. checks the user can view a category but not that
   they own or may edit the specific item).
2. **Backend-only tasks leaking into frontend or api controllers, or vice versa** — a task meant only
   for administrator use (bulk state changes, configuration, anything with irreversible or
   site-wide effect) reachable through a frontend or api application controller, whether by a shared
   base controller, a copy-pasted task method, or a dispatcher that doesn't distinguish applications.
   Also check the reverse: a task genuinely meant for public/frontend use that's absent from the
   backend, forcing an inconsistent or insecure workaround.
3. **Arbitrary/unsafe uploads** — independent of whether the upload endpoint is properly authenticated
   and authorised (that's `audit-authz`'s job), assess the upload handling itself:
   - Is the accepted file type validated with an **allow-list** (extension and, where feasible,
     actual MIME/content sniffing), not a deny-list?
   - Is the stored filename/path **unpredictable** — not the original filename verbatim, not a
     sequential or otherwise guessable ID — so a successful upload can't be located and executed by
     URL guessing?
   - Is the storage location outside any web-executable path, or does it have execution disabled
     there (`.htaccess`/`web.config` denying script execution, or storage entirely outside the
     webroot)?
   - Is the filename or any path/subdirectory parameter free of path traversal (`../`, absolute
     paths, null bytes)?

## Context

Joomla routes a request to the component's Dispatcher first (default:
`\Joomla\CMS\Dispatcher\ComponentDispatcher`, if no custom one is provided), then to a Controller
whose `execute()` routes to a task handler. Parent classes and the Dispatcher may legitimately
implement checks instead of the leaf controller — that's fine as long as the *right* check happens
somewhere on every reachable path, for every application (backend/frontend/api) the task is reachable
from.

## Scope

Audit all controllers across backend, frontend, and api application views (whichever exist) — the
same footprint as `audit-authz` — plus any file-upload handling reachable from them (component
controllers, but also model/helper code the controller delegates the actual upload to).

## Actions

### Step 1: Audit

Report findings ordered by severity, using these criteria:

- **CRITICAL** — an arbitrary upload with a predictable stored path/name landing in a web-executable
  location, or a backend-only destructive/administrative task fully reachable and effective from the
  frontend or api application.
- **HIGH** — a mismatched privilege check that lets a lower-privileged user perform a
  higher-privileged create/edit/publish action; an upload allow-list gap (wrong extension accepted)
  behind otherwise-correct auth; a backend task leaking into frontend/api but requiring an
  already-elevated account to exploit.
- **MEDIUM** — a mismatched privilege check with limited blast radius (read-only leak, or requires
  access already close to what's being checked); upload storage in an execution-disabled but
  otherwise web-reachable path.
- **LOW** — a mismatch that over-restricts rather than under-restricts (an adequately privileged user
  is wrongly blocked) — a bug, not a security issue, but worth listing since it's the same code path.

Report and await operator feedback.

### Step 2: Feedback round

The operator is a subject matter expert who may ask you to reevaluate, reclassify, or overrule a
finding after giving more context.

### Step 3: Plan fixes

Once the operator is done giving feedback, check for remaining items to fix.

If none, say so and stop.

Otherwise, break the fixes into smaller, individually implementable plans and write them to the
`.gitignore`'d `.plans` directory (clearing any existing files there first). Then propose running
those plans in parallel via subagents/workflows, using the cheaper Sonnet model since the planning
work is already done.
