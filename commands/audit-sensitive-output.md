---
description: Audit Joomla extension responses, logs, exports, errors, mail, and caches for injection or sensitive-data disclosure.
---

# Joomla sensitive output and non-HTML injection audit

Audit non-HTML output sinks for data disclosure, injection into downstream interpreters, and accidental
reuse of private output across users.

## Boundaries

This audit owns response headers, downloads, CSV/spreadsheet exports, logs, exceptions/error responses,
outbound mail construction, and cache isolation. Browser HTML/JavaScript execution belongs to
`audit-xss`; secret creation and cryptographic handling belong to `audit-secrets-crypto`; object-level
selection of records belongs to `audit-object-access`. Cross-reference shared causes instead of
duplicating them.

## Sinks and checks

Trace request values, headers, database content, extension parameters, remote responses and exception
data into:

- HTTP headers and redirects: reject CR/LF and control characters, construct `Content-Disposition`
  safely, and keep attacker values out of security/caching headers;
- CSV/spreadsheet exports: neutralise cells beginning with formula control characters as required by
  the target format while preserving the intended data;
- logs and audit trails: prevent log forging/control-character injection and avoid credentials,
  tokens, session identifiers, personal data or unbounded attacker content;
- exceptions, debug pages and API errors: avoid stack traces, filesystem paths, queries, configuration,
  secrets and oracle-like differences reaching unauthorised users;
- mail recipients, sender/reply-to/subject and multipart boundaries: prevent header/recipient injection
  and unauthorised use as a relay or bulk-mail endpoint;
- caches: include identity, access level, language, tenant and other security-relevant context in cache
  variation; do not publicly cache private responses; prevent a privileged/error response from being
  served to another user.

Recognise framework APIs that reject unsafe headers or correctly partition caches. A value being
personal or attacker-controlled is not itself a finding; establish that the sink mishandles it or
exposes it to an unintended audience.

## Workflow

Report findings ordered by severity:

- **CRITICAL** — unauthenticated disclosure of credentials or broad highly sensitive datasets, or a
  cache isolation failure exposing privileged content widely.
- **HIGH** — exploitable mail relay, persistent log/audit forgery affecting security decisions,
  sensitive cross-user cache leakage, or formula injection in a likely privileged workflow.
- **MEDIUM** — stack/query/path disclosure, constrained personal-data leakage, header injection with
  limited impact, or formula injection requiring significant interaction.
- **LOW** — excessive but non-sensitive diagnostics or defence-in-depth output hardening.

For each finding give the data source, output sink/format, unintended interpreter or audience,
privileges, impact and format-correct mitigation, with file and line references. Keep any discovered
secret or personal data redacted. Report and await operator feedback before changes, then propose
independent fixes for accepted findings.
