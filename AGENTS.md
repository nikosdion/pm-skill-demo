# AGENTS.md

This file provides guidance to Claude Code, Codex, and Qwen Code when working with code in this repository.

## Deploying changes

Edits here are NOT live until installed. Choose the host you are deploying to:

- **Claude Code** — run `./install-claude.sh`. This rebuilds the ZIP, replaces `~/.claude-plugins/pm-skill-demo/`, registers the plugin in the local marketplace, and reinstalls it. Then run `/reload-plugins` in Claude Code.
- **Codex** — run `./install-codex.sh`. This installs a clean copy under `~/plugins/pm-skill-demo/`, registers it in the personal marketplace, and installs via the Codex CLI. Start a new Codex conversation to load it.
- **Qwen Code** — run `./install-qwen.sh`. This links the repo root via `qwen extensions link`. Restart Qwen Code to pick up the link; subsequent edits are live after each restart.

**Bump the version in every manifest for every content change.** The Claude cache is keyed by `.claude-plugin/plugin.json`; the Codex install mirrors whatever sits in `.codex-plugin/plugin.json`; the Qwen Code manifest in `qwen-extension.json` is informational but documents the loaded release. If any of them does not change, the corresponding host keeps serving the previous version.

## Skill authoring conventions

- The `description` frontmatter field is the trigger — be precise. Too broad and the skill fires spuriously; too narrow and it misses.
- `audit-authz`, `audit-sql-filtering`, and `audit-controller-exposure` cross-reference each other so their controller-security scopes don't overlap: `audit-authz` owns missing auth/authorisation/CSRF checks, `audit-sql-filtering` owns SQL injection, `audit-controller-exposure` owns mismatched privilege checks, backend-only task leakage, and unsafe uploads. Keep the cross-references (in both the `SKILL.md` descriptions and the `commands/*.md` bodies) consistent if any of their scopes change.
- The other security audits are organised by sink family: `audit-xss` owns browser execution contexts; `audit-file-operations` owns filesystem and archive paths after initial upload handling; `audit-code-execution` owns server-side execution; `audit-ssrf-redirects` owns outbound URLs and redirects; `audit-object-access` owns per-object isolation beyond the controller gate; `audit-secrets-crypto` owns secret and cryptographic properties; `audit-package-surface` owns the released artifact; and `audit-sensitive-output` owns non-HTML output and cache isolation. Preserve these boundaries and their cross-references instead of growing a generic input-validation audit.
- `php-conservative` and `php-upcoming` split the supported PHP range between them, and each says so explicitly: `php-conservative` owns everything the PHPCompatibility sniffs have data for, `php-upcoming` owns everything above that, which only a test run on the actual PHP can cover. Both drive PHP_CodeSniffer with the PHPCompatibility standard directly — this fork has no dependency on any external build toolchain. Three details are load-bearing and must stay consistent in both files: that the sweep is read-only (`phpcs`, never `phpcbf`), that its `testVersion` range is derived from `require.php` rather than taken by hand, and that it must be clamped to whatever ceiling the installed PHPCompatibility release actually has sniff data for, with a warning — because a sniff run against a PHP version it has no data for reports nothing, which reads exactly like a pass. Both files also tell the reader not to use Rector, and why; if that ever changes, change it in both.
- `e2e-tests` covers Joomla extensions and standalone PHP projects only — no WordPress support in this fork.

## Git: commit and tag outside the sandbox

Commits and tags are always signed, with a key held in 1Password. The 1Password signing agent is reached
over a local socket that agent sandboxes do not expose, so a sandboxed `git commit` or `git tag` **always**
fails (e.g. `error: 1Password: Could not connect to socket. Is the agent running?`).

Run every `git commit` and `git tag` **outside the sandbox from the first attempt** — in Claude Code with
`dangerouslyDisableSandbox: true`, in other harnesses with their equivalent unsandboxed / escalated
execution. Do not try the sandboxed form first, do not diagnose the failure, and never work around it
with `--no-gpg-sign`, `-c commit.gpgsign=false` or unsigned tags.

## Project memory

Project memory lives in `.claude/memory/`, committed with the code, so that it is shared across machines
and across agentic harnesses (Claude Code, Codex, Qwen Code, Kimi Code, Junie, …).

There are no memory files yet. When there is something worth remembering, create `.claude/memory/`,
the topic file, and a table here mapping each file to a concrete trigger ("Before you… | Read").

### Recording new memories

This is the **default and only** place for project memory. Do not write memories for this project to a
harness's private memory store (such as Claude Code's auto-memory under `~/.claude/projects/`); write
them here instead:

- Add to the existing topic file when one fits; otherwise create a new kebab-case `.md` file named after
  the topic, and add a row for it to the table above with a concrete trigger.
- Plain Markdown, no frontmatter. State the rule, then **Why:** (the reason or incident behind it) and
  **How to apply:**. Link related files with relative Markdown links.
- Don't record what the code, Git history or an existing `AGENTS.md` already says — update that
  `AGENTS.md` instead when the rule belongs there. Remove or correct entries that turn out wrong.
- These files are committed: no secrets, credentials, customer data or personal details.
