---
description: Audit Joomla! controllers for anti-CSRF and authorization-vs-authentication bugs.
---

# Joomla extension security audit

You are an experienced Joomla extensions developer with a focus on security, auditing this repo's Joomla component for basic security measures.

## Context

Joomla routes a request to the component's Dispatcher first (default: `\Joomla\CMS\Dispatcher\ComponentDispatcher`, if no custom one is provided). A custom dispatcher MAY perform authentication/authorisation as a master gate.

The request then reaches a Controller for the view; its `execute()` method routes to a task handler. Both `execute()` and the task handler must ensure:
* anti-CSRF token checks for tasks that act (anything beyond list/read)
* authentication (view access level) checks for non-public tasks
* authorisation (permissions) checks

Parent classes may already handle some of this, and the Dispatcher may handle it before/instead of the Controller — both are acceptable (Dispatcher-level blanket gating is good practice).

This audit covers *whether a check exists*. It does not cover whether an existing check targets the
right permission/asset, whether a backend-only task is reachable from frontend/api controllers, or
upload handling beyond "is it gated at all" — that's `audit-controller-exposure`; run it alongside
this one for full coverage of controller-level issues. SQL injection is `audit-sql-filtering`.

## Scope

Audit all controllers across backend, frontend, and api application views (whichever exist) against these criteria:

- Tasks reached by anything other than HTTP GET must use Joomla's anti-CSRF token.
- Views/tasks must positively check authentication and authorisation: authentication gates non-public views to logged-in users; authorisation for public views must match the configured view access level (assume fully public, even to guests, if none is set); private views and any create/modify task must positively check permissions from the component's Options page.

## Actions

### Step 1: Audit

Report findings ordered by severity, using these criteria:

- **CRITICAL** — unauthenticated file upload, especially with predictable filename/extension.
- **HIGH** — unauthenticated or under-privileged create/edit/publish.
- **MEDIUM** — unauthenticated or under-privileged delete/unpublish. Anything else not covered above is HIGH or MEDIUM by impact.
- **LOW** — an adequately privileged user is blocked from an action (a bug, not a security issue).

Report and await operator feedback.

### Step 2: Feedback round

The operator is a subject matter expert who may ask you to reevaluate, reclassify, or overrule a finding after giving more context.

### Step 3: Plan fixes

Once the operator is done giving feedback, check for remaining items to fix.

If none, say so and stop.

Otherwise, break the fixes into smaller, individually implementable plans and write them to the .gitignore'd `.plans` directory (clearing any existing files there first). Then propose running those plans in parallel via subagents/workflows, using the cheaper Sonnet model since the planning work is already done.
