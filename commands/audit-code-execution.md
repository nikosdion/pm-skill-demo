---
description: Audit Joomla extensions for attacker-influenced server-side code, command, and object execution sinks.
---

# Joomla server-side execution audit

Audit the distributed extension for attacker-influenced data reaching a server-side execution or
object-instantiation sink.

## Boundaries

This audit owns OS command injection, dynamic PHP execution/inclusion, unsafe deserialisation, and
attacker-selected callables, classes, templates, or service factories that can execute unintended
code. Browser-side JavaScript execution belongs to `audit-xss`; path escape at ordinary filesystem
operations belongs to `audit-file-operations`; HTTP fetches belong to `audit-ssrf-redirects`.

## Sinks and controls

Trace request data, headers, cookies, database records, extension configuration, filenames, remote
responses, queue/job payloads, cache entries, and webhook bodies into:

- `exec`, `system`, `shell_exec`, `passthru`, `proc_open`, `popen`, backticks, or libraries that invoke
  external programs;
- `eval`, string assertions where supported, generated PHP, dynamic `include`/`require`, and template
  compilation or rendering that treats data as code;
- `unserialize` and equivalent object reconstruction, including PHAR metadata reached through file
  operations on affected runtimes/libraries;
- dynamic callables, event names, class names, service aliases, reflection, and dependency-container
  lookups where an attacker can select something outside a strict allow-list.

Do not assume shell escaping makes a command safe: determine whether arguments can alter option
parsing, executable selection, environment, working directory, or shell syntax. Prefer direct library
APIs or argument-vector execution. For structured data prefer JSON; where legacy deserialisation is
unavoidable verify integrity/authenticity before parsing and restrict allowed classes. Recognise fixed
maps and framework-controlled dispatch before reporting.

## Workflow

Report findings ordered by severity:

- **CRITICAL** — reliable remote code or command execution reachable by a guest or low-privilege user.
- **HIGH** — exploitable execution requiring authentication, or unsafe deserialisation of data whose
  integrity an attacker can influence.
- **MEDIUM** — execution requiring elevated extension privileges, a strong gadget/environment
  prerequisite, or a constrained command argument injection.
- **LOW** — dangerous machinery currently fed only by trusted constants but likely to become unsafe.

For each finding document the source-to-sink chain, attacker control, required environment or gadget,
impact, and the narrowest safe redesign, with file and line references. Avoid claiming deserialisation
RCE without establishing attacker control and a plausible gadget path; label unverified gadget
availability clearly. Report and await operator feedback before changes, then propose independent
fixes for accepted findings.
