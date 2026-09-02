---
description: Audit Joomla extension URL flows for server-side request forgery and unsafe redirects.
---

# Joomla outbound URL and redirect audit

Audit attacker-influenced URLs that reach either a server-side network client or a browser redirect.

## Boundaries

This audit owns SSRF, unsafe URL schemes, redirect-based allow-list bypasses, and open redirects. Local
filesystem wrappers and includes belong to `audit-file-operations`; command execution belongs to
`audit-code-execution`; URL output that executes script in the current page belongs to `audit-xss`.

## Server-side requests

Trace URLs, hosts, ports and proxy settings from requests, database records, imports, webhooks,
extension parameters and remote responses into Joomla HTTP clients, cURL, sockets, URL-aware streams,
image/PDF metadata fetchers, link previews, importers and callback verification.

Where the destination is not a fixed trusted endpoint, verify an appropriate policy covers schemes,
credentials, hosts, ports and resolved addresses. Check IPv4 and IPv6 loopback, private, link-local,
unspecified, multicast and cloud-metadata destinations; unusual numeric/encoded host forms; DNS changes;
and proxies. Every followed redirect must be resolved and validated again. Consider whether the client
forwards credentials or sensitive headers across hosts and whether response size/time are bounded.

An administrator-configured URL is lower exposure, not automatically safe: assess delegated roles,
stored-value tampering, imports, and whether reaching internal services exceeds the administrator's
intended Joomla privileges.

## Browser redirects

Inspect Joomla redirects and raw `Location` headers. Relative internal destinations or fixed maps are
preferred. For external redirects require an explicit, normalised scheme/host/port policy; reject
scheme-relative URLs, user-info tricks, control characters and ambiguous parser forms. Do not confuse
an untrusted post-login return URL with harmless internal routing.

## Workflow

Report findings ordered by severity:

- **CRITICAL** — guest/low-privilege access to internal metadata, management services, or credentialed
  network resources.
- **HIGH** — general SSRF, credential forwarding to attacker infrastructure, or a highly credible
  authentication-flow open redirect.
- **MEDIUM** — blind/constrained SSRF, elevated-user-only SSRF, or an ordinary phishing redirect.
- **LOW** — incomplete hardening without a demonstrated attacker-controlled destination.

For each finding show the URL source, normalisation and validation, sink, redirect behaviour,
privileges, reachable target class and mitigation, with file and line references. Note runtime/DNS
assumptions. Report and await operator feedback before modifying code, then propose independent fixes.
