# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Deploying changes

Edits here are NOT live until installed. Choose the host you are deploying to:

- **Claude Code** — run `./install-claude.sh`. This rebuilds the ZIP, replaces `~/.claude-plugins/pm-skill-demo/`, registers the plugin in the local marketplace, and reinstalls it. Then run `/reload-plugins` in Claude Code.
- **Codex** — run `./install-codex.sh`. This installs a clean copy under `~/plugins/pm-skill-demo/`, registers it in the personal marketplace, and installs via the Codex CLI. Start a new Codex conversation to load it.
- **Qwen Code** — run `./install-qwen.sh`. This links the repo root via `qwen extensions link`. Restart Qwen Code to pick up the link; subsequent edits are live after each restart.

**Bump the version in every manifest for every content change.** The Claude cache is keyed by `.claude-plugin/plugin.json`; the Codex install mirrors whatever sits in `.codex-plugin/plugin.json`; the Qwen Code manifest in `qwen-extension.json` is informational but documents the loaded release. If any of them does not change, the corresponding host keeps serving the previous version.

## Skill authoring conventions

- The `description` frontmatter field is the trigger — be precise. Too broad and the skill fires spuriously; too narrow and it misses.
- `audit-authz`, `audit-sql-filtering`, and `audit-controller-exposure` cross-reference each other so their controller-security scopes don't overlap: `audit-authz` owns missing auth/authorisation/CSRF checks, `audit-sql-filtering` owns SQL injection, `audit-controller-exposure` owns mismatched privilege checks, backend-only task leakage, and unsafe uploads. Keep the cross-references (in both the `SKILL.md` descriptions and the `commands/*.md` bodies) consistent if any of their scopes change.
- `php-conservative` and `php-upcoming` split the supported PHP range between them, and each says so explicitly: `php-conservative` owns everything the PHPCompatibility sniffs have data for, `php-upcoming` owns everything above that, which only a test run on the actual PHP can cover. Both drive PHP_CodeSniffer with the PHPCompatibility standard directly — this fork has no dependency on any external build toolchain. Three details are load-bearing and must stay consistent in both files: that the sweep is read-only (`phpcs`, never `phpcbf`), that its `testVersion` range is derived from `require.php` rather than taken by hand, and that it must be clamped to whatever ceiling the installed PHPCompatibility release actually has sniff data for, with a warning — because a sniff run against a PHP version it has no data for reports nothing, which reads exactly like a pass. Both files also tell the reader not to use Rector, and why; if that ever changes, change it in both.
- `e2e-tests` covers Joomla extensions and standalone PHP projects only — no WordPress support in this fork.
