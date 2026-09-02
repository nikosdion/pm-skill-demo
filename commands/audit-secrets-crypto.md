---
description: Audit Joomla extensions for exposed secrets, weak security tokens, and unsafe cryptographic use.
---

# Joomla secrets and cryptography audit

Audit distributed files and runtime flows for secret exposure, weak authentication tokens, unsafe
password handling, and cryptographic designs that do not provide their claimed property.

## Boundaries

This audit owns credentials and key material, random token generation, token comparison, password
storage, signing, encryption and key lifecycle. Secrets exposed specifically through logs, errors,
caches, exports or response headers also belong to `audit-sensitive-output`; cross-reference a shared
root cause rather than duplicate it. Webhook request authorisation belongs to `audit-authz`, while the
correctness of its signature construction and comparison belongs here.

## What to inspect

- committed passwords, API tokens, private keys, signing secrets, connection strings and realistic
  production credentials in source, fixtures, SQL, manifests, build files and packaged artifacts;
- secrets embedded in URLs, browser-visible markup, JavaScript, client configuration, exception text,
  telemetry, or values readable by users who do not need them;
- tokens, nonces, reset links, API keys and filenames generated with predictable values such as time,
  counters, `rand`, `mt_rand`, `uniqid`, hashes of public data, or insufficient random bytes;
- secret/token comparison that leaks timing or tolerates type juggling, truncation, case folding, or
  ambiguous encodings;
- plaintext or reversibly encrypted passwords, obsolete password hashes, static IVs/nonces, unauthenticated
  encryption, reused nonces, hard-coded encryption keys, confused signing/encryption, and home-grown
  algorithms;
- rotation, revocation, expiry and separation of keys when the extension's design claims these properties.

Do not flag examples, obvious placeholders, public keys, hashes, test-only fixtures excluded from the
package, or Joomla-generated secrets merely because they resemble random strings. Use entropy/format
checks only for discovery and verify context. Never print a complete discovered secret: identify its
location and type and show only a minimal redacted fingerprint if needed.

## Workflow

Report findings ordered by severity:

- **CRITICAL** — a live or plausibly live privileged credential/private key in distributed or public
  material, or trivial forgery of a high-impact authentication token.
- **HIGH** — predictable reset/API/session-equivalent tokens, plaintext password storage, or broken
  encryption/signature logic exposing protected data or authority.
- **MEDIUM** — secrets exposed to an unnecessarily broad authenticated audience, weak lifecycle
  controls, or exploitation requiring substantial samples/access.
- **LOW** — legacy or fragile cryptography with no demonstrated security impact in its current use.

For every finding state the intended security property, material or operation involved, exposure or
failure mode, attacker prerequisites, impact and a migration-safe mitigation, with file and line
references. Recommend revocation/rotation when exposure may already have occurred, without performing
it. Report and await operator feedback before code changes.
