---
description: Audit attacker-influenced filesystem paths and archive entries in Joomla extensions.
---

# Joomla filesystem operation audit

Audit distributed extension code for attacker-influenced paths reaching filesystem operations outside
the intended root or with unintended semantics.

## Boundaries

This audit owns reads, downloads, writes, moves, copies, renames, deletes, includes, directory
operations, stream wrappers, symlink handling, and archive extraction. File type acceptance and the
initial storage of HTTP uploads belong to `audit-controller-exposure`; authentication and authorisation
of the calling task belong to `audit-authz` and `audit-controller-exposure`. Continue tracing uploaded
names into later filesystem operations, but cross-reference rather than duplicate upload findings.
Remote HTTP requests belong to `audit-ssrf-redirects`; command execution belongs to
`audit-code-execution`.

## What to trace

Treat request values, headers, form arrays, database content, extension parameters, remote metadata,
uploaded names, and archive entry names as potential sources. Inspect native PHP filesystem functions,
Joomla filesystem helpers, download/preview endpoints, dynamic `include`/`require`, template and layout
selection, log/export paths, cleanup jobs, installers, and archive libraries.

For each path verify, as applicable:

- it is resolved against an explicit allowed root, canonicalised, and checked with a boundary-aware
  comparison rather than a string prefix;
- absolute paths, parent traversal, NULs, alternate separators, stream-wrapper schemes, and encoded or
  double-decoded traversal cannot change the target;
- existing symlinks and symlinked parents cannot escape the allowed root, including between a check
  and a write/delete operation;
- allow-listed logical identifiers are mapped to server-selected paths instead of being concatenated;
- archive entries cannot escape the extraction directory (Zip Slip), create unsafe links, overwrite
  sensitive files, or expand without useful limits;
- downloads cannot disclose arbitrary local files and deletion/cleanup cannot target unrelated data.

Joomla's `PATH` input filter validates path syntax; it does not prove that a path is beneath the
extension's permitted root.

## Workflow

Report findings ordered by severity:

- **CRITICAL** — attacker-controlled PHP inclusion, write into an executable/configuration location,
  or arbitrary destructive deletion with guest or low-privilege reachability.
- **HIGH** — arbitrary file read, archive traversal, or a write/delete escaping the intended root
  behind ordinary authenticated access.
- **MEDIUM** — constrained disclosure or modification, or exploitation requiring elevated extension
  privileges.
- **LOW** — fragile root enforcement or symlink/TOCTOU hardening with no demonstrated escape.

For each finding show source, path construction, sink, expected root, bypass, privileges and impact,
with file and line references and a concrete mitigation. Distinguish confirmed paths from runtime
questions. Report and await operator feedback before applying changes, then propose independent fixes
for accepted findings.
