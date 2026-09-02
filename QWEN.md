# QWEN.md

This file provides guidance to Qwen Code when working with code in this repository.

## Deploying changes

Edits here are NOT live until Qwen Code is restarted. Run:

```bash
./install-qwen.sh
```

This links the current repo into Qwen Code's extensions directory via `qwen extensions link`. The link is a symlink, so subsequent file edits take effect after restarting Qwen Code (no script rerun required unless you moved the repo).

**Bump `version` in `qwen-extension.json` for every content change.** The version is informational metadata that documents which release of the plugin is loaded. It does not gate caching — Qwen Code picks up the latest symlinked content on each restart — but it is what tells users which build they have.

Do not hand-copy individual files into `~/.qwen/extensions/` — that misses `commands/` and `skills/` resources.

## Skill authoring conventions

- The `description` frontmatter field is the trigger — be precise. Too broad and the skill fires spuriously; too narrow and it misses.
- `audit-authz`, `audit-sql-filtering`, and `audit-controller-exposure` cross-reference each other so their controller-security scopes don't overlap. Keep the cross-references consistent if any of their scopes change.
