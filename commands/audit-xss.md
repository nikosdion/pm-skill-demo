---
description: Audit Joomla extension output paths for reflected, stored, and DOM-based cross-site scripting.
---

# Joomla cross-site scripting audit

Audit this repository's distributed Joomla extension code for attacker-influenced data reaching a
browser execution context without protection appropriate to that exact context.

## Boundaries

This audit owns reflected, stored, and DOM-based XSS. It does not own SQL injection
(`audit-sql-filtering`), response-header or CSV injection (`audit-sensitive-output`), or server-side
code execution (`audit-code-execution`). Do not report a merely unfiltered value unless it reaches an
XSS-capable sink.

## Sources and sinks

Trace values from request data, cookies, headers, routing data, form arrays, database records,
extension parameters, remote responses, and previously stored rich text. Administrator-supplied
content is not automatically trusted; account compromise and delegated administration still make
stored XSS relevant, though privilege affects severity.

Inspect PHP layouts, view templates, modules, plugins, emails rendered as HTML, custom documents,
JavaScript, and API data later inserted into the DOM. Cover at least:

- HTML text and attribute output, including hand-built tags and `data-*` attributes;
- URL-valued attributes, including dangerous schemes;
- inline JavaScript and script options, JSON embedded in HTML, and event-handler attributes;
- DOM sinks such as `innerHTML`, `outerHTML`, `insertAdjacentHTML`, `document.write`, and jQuery HTML
  insertion when their value is not demonstrably safe;
- intentionally allowed HTML whose allow-list permits executable tags, attributes, CSS, or URLs.

Input filtering is defence in depth, not a substitute for output encoding. Verify the protection is
correct for the destination: HTML escaping is not sufficient for JavaScript, JSON, CSS, or URL
contexts. Recognise framework helpers and escaping performed by a parent layout before reporting.

## Workflow

Map each source-to-sink path and determine whether an attacker with the stated privileges can control
the final value. Report only exploitable or convincingly risky paths, ordered by severity:

- **CRITICAL** — stored XSS reliably executed for super users or across the administrator application
  from guest or low-privilege input.
- **HIGH** — stored XSS affecting other users, or reflected/DOM XSS requiring little user interaction.
- **MEDIUM** — self-XSS with a credible escalation path, administrator-only stored XSS, or an exploit
  requiring significant interaction.
- **LOW** — defence-in-depth weaknesses where executable output is plausible but not currently
  attacker-controlled.

For every finding give the source, transformations, sink and output context, attacker prerequisites,
affected users, and a context-correct mitigation. Include file and line references. Separate confirmed
findings from items that require runtime verification. Report and await operator feedback before
changing code. After feedback, propose small independent fixes for the remaining accepted findings.
