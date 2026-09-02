---
description: Audit Joomla record access paths for IDOR, BOLA, ownership bypass, and cross-user data leakage.
---

# Joomla object-level access audit

Audit whether every attacker-selectable record, collection, export, attachment, and API object is
constrained to what the current user may view or modify.

## Boundaries

This audit owns IDOR/BOLA and data isolation across models, tables, repositories, API serializers,
downloads, AJAX handlers, plugins, modules, custom fields, web services, jobs and CLI-to-web bridges.
Whether a controller has any access check belongs to `audit-authz`; whether it checks the correct
permission or asset at that entry point belongs to `audit-controller-exposure`. This audit follows the
identifier into the data operation and response to find missing per-object constraints. SQL syntax
safety belongs to `audit-sql-filtering`.

## What to verify

Inventory attacker-selectable identifiers from routes, query/body data, arrays used for bulk actions,
filters, aliases, filenames and relationship IDs. Trace them through reads, writes, deletes, state
changes, copies, exports and serialization. Account for Joomla access levels, category/item assets,
ownership (`core.edit.own`), created-by assignment, publication state, language, tenant/site/customer
boundaries, and parent-child relationships used for nested objects.

Check that:

- list queries and counts apply the same access constraints as single-record reads;
- API fields, relationships, totals and error differences do not disclose inaccessible objects;
- bulk operations validate every ID and fail safely instead of authorising only the first or parent;
- submitted ownership, asset, state, user, group or tenant fields cannot be mass-assigned beyond the
  actor's privileges;
- opaque or unguessable IDs are not treated as authorisation;
- caches and helper methods do not reuse a privileged lookup in a less-privileged context.

Recognise constraints enforced centrally by a parent model, table, query helper, serializer, plugin or
database view before reporting.

## Workflow

Report findings ordered by severity:

- **CRITICAL** — guest or low-privilege access to secrets, credentials, or broad private datasets, or
  cross-tenant destructive modification.
- **HIGH** — reading or modifying another user's protected records, ownership takeover, or publication
  of inaccessible records.
- **MEDIUM** — limited metadata disclosure, constrained cross-user access, or elevated-role isolation
  failure.
- **LOW** — inconsistent over-restriction or defence-in-depth gaps without a current bypass.

For each finding identify the entry point, identifier, data operation, missing constraint, effective
actor, exposed action/data and mitigation, with file and line references. Include a representative
request or call path when useful. Report and await operator feedback before changes, then propose
independent fixes for accepted findings.
