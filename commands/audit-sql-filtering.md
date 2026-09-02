---
description: Audit code for values filtering in SQL queries
---

# Audit filtering for values ending up in SQL queries

Audit this Joomla component for unsafe validation/escaping of data that ends up in SQL queries.

## Context

Filter values (from filter subforms, user state via `getUserStateFromRequest`, or user input) flow into the Model and build SQL queries for counting and selecting records. Unsafe values are a prime source of SQL injection, including blind/bit-oracle attacks (a record shows or doesn't, leaking one bit at a time).

Assess severity by attack surface:
- **Backend views** — requires an authenticated administrator.
- **Frontend** — may be guest-accessible or low-privilege; more severe.
- **API application** — severity similar to the frontend depending on setup.

Correct mitigation: retrieve each filter value with the appropriate Joomla filter, type-cast non-string values (e.g. integer), and **always use prepared queries with explicit named parameters for every piece of data from filters, user state, or user input**.

This audit is scoped to SQL injection specifically. For missing authentication/authorisation/CSRF
checks, see `audit-authz`; for mismatched privilege checks, backend-task leakage, and unsafe uploads,
see `audit-controller-exposure`.

## Actions

Report each vulnerable location with an estimated severity, followed by a comprehensive itemised list of proposed mitigations. Present the list for my review before applying anything.
