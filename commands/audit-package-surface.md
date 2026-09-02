---
description: Audit Joomla release packages for unintended files, executable entry points, unsafe installer behaviour, and vulnerable dependencies.
---

# Joomla release package surface audit

Audit what the project's build actually distributes and installs, not just what exists in the source
tree. Identify files, entry points, installer behaviour and third-party code that unnecessarily enlarge
the production attack surface.

## Boundaries

This audit owns package composition, manifest/build mismatches, unintended directly reachable files,
installer/update surfaces, and deterministic dependency-vulnerability checks. Vulnerabilities inside
first-party sinks belong to their dedicated audits. Missing `_JEXEC` guards in intended extension PHP
files belong to `audit-jexec`; report unintended shipped PHP here and cross-reference rather than
duplicating the guard finding.

## Establish the package

Read the extension manifests, package/build scripts, ignore rules and Composer/npm production settings.
When safe and already supported by the repository, build the same artifact released to users and
inspect its file list. Do not assume every Git file ships or that every generated package file is in
Git. Do not install dependencies or contact registries without the operator's authorisation.

Check for:

- backups, editor files, SQL dumps, logs, debug tools, test fixtures, CI/development configuration,
  source credentials, private keys, source maps, sample applications, vendor demos, diagnostic pages
  and alternate entry points;
- executable PHP in media or other directly addressable locations, unexpected writable-plus-executable
  directories, and files omitted from uninstall or upgrade cleanup where continued reachability matters;
- manifest paths that install broader trees than intended, stale files retained across upgrades,
  unsafe installer scripts, and update/download URLs lacking transport or package authenticity expected
  by the supported Joomla versions;
- production packages containing development dependencies or unnecessary tools/interpreters;
- known vulnerabilities in locked production dependencies using the ecosystem's lockfile-aware audit
  command when available. Record tool/database freshness and treat unconfirmed name/version matches as
  leads, not proof.

Minified assets, legitimate public keys, and test files that are provably excluded from every release
artifact are not findings.

## Workflow

Report findings ordered by severity:

- **CRITICAL** — a packaged credential/backdoor or directly reachable tool enabling unauthenticated
  code execution or takeover.
- **HIGH** — a shipped vulnerable production dependency with a reachable high-impact path, executable
  demo/diagnostic surface, or private data in the artifact.
- **MEDIUM** — unnecessary reachable code, unsafe upgrade residue, production development dependency,
  or a vulnerable dependency whose exploitability is constrained or unknown.
- **LOW** — metadata/source disclosure or packaging hardening without a demonstrated exploit.

For each finding distinguish source-tree presence from release-artifact presence, identify the rule
that includes it, explain reachability and impact, and propose the smallest packaging/build correction.
Include dependency advisory identifiers and locked versions where applicable. Report and await operator
feedback before changing package rules or dependencies.
