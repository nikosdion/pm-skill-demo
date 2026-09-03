# Project Management Skills for Joomla

**AI coding assistant skills for managing Joomla software projects**

> [!NOTE]
> Like the AI coding assistants themselves, this commands and skills plugin works best on Linux (bare metal, VM, or WSL2) and macOS. It's not been tested on Windows; if you're on Windows, please use WSL2.

## Summary

A triple Claude Code, Codex, and Qwen Code plugin providing AI coding assistant skills to make your life easier developing and maintaining Joomla software projects.

- **Security auditing**. Audit your extensions for common security issues, generic and Joomla-specific.
- **Deprecation handling**. Add compatibility with upcoming PHP and Joomla versions, drop no llonger necessary workarounds.
- **Translation management**. English en-GB consistency, machine-translate to other languages using glossaries.
- **Code QA**. Create and maintain end-to-end (E2E) tests – unit and integration.
- **Utility**. Plan and execute long, complex tasks.

Joomla is stronger when all of its extensions are secure, well-maintained, and compatible with the newest PHP and Joomla versions. It promotes user trust to the Joomla ecosystem, which is to everyone's benefit.

The commands and skills in this repository help towards that direction. These are the same commands and skills I use every day. They make the security and quality upkeep of your Joomla software cost less, take less of your time, be less error-prone, and no longer require deep expertise.

## Examples

You can use the commands as per the Installation instructions below. Alternatively, and most recommended, you can use the skills using natural language requests.

- Audit a Joomla component repository for every security issue:

  > Audit this Joomla component repository for security issues. Use all the provided security-audit skills and give me one consolidated report of your findings.

- Audit a Joomla component repository for a specific security issue:

  > Audit this Joomla component repository for anti-CSRF and authorization-vs-authentication bugs using the audit-authz skill.

- Address compatibility with an upcoming PHP release:

  > Make this project compatible with the upcoming PHP 8.6 release while preserving its existing supported PHP version range.

- Address compatibility with an upcoming Joomla release:

  > Update this extension for compatibility with the upcoming Joomla 7.0 release. Identify the relevant Joomla deprecations and make backwards-compatible changes wherever possible.

- Implement unit and E2E integration tests for a specific support matrix:

  > Implement PHPUnit unit tests and Docker-based E2E integration tests for every PHP version that `composer.json` claims to support, running the integration tests on Joomla 5.4 and 6.1.

- Machine-translate an extension:

  > Machine-translate this Joomla extension into all languages supported by the translation skill, preserving plural forms and extension-specific terminology.

- Plan and execute a substantial migration:

  > Use plan-and-execute to upgrade all backend views from Bootstrap 3 to Bootstrap 5.3 CSS classes. Carry out the entire plan and verify the result.

## Installation

Run the provided scripts to install these commands and skills into your AI coding assistant.

**Requirements**: `rsync`, `zip`, `unzip`, `php`, and the coding assistant's executable (`claude`, `codex`, or `qwen`) on your `$PATH`.

### Claude Code

```bash
bash install-claude.sh
```

This script:
1. Builds a clean ZIP (`pm-skill-demo.zip`) excluding dev-only files.
2. Unpacks it into `~/.claude-plugins/pm-skill-demo/`.
3. Creates `~/.claude-plugins/.claude-plugin/marketplace.json` if it doesn't exist.
4. Registers the plugin in that marketplace file (idempotent — safe to run again).
5. Adds the local marketplace, updates it, and installs the plugin via the Claude Code CLI.

Run `/reload-plugins` and `/reload-skills` in an open Claude Code session, or restart your session to take effect.

### Codex

```bash
bash install-codex.sh
```

This script:

1. Installs a clean copy under `~/plugins/pm-skill-demo/`.
2. Creates or updates the entry in Codex's personal marketplace at `~/.agents/plugins/marketplace.json`.
3. Installs the plugin with the Codex CLI.

Start a new Codex conversation after installation so the new skills are loaded. Invoke a converted command explicitly with its namespaced skill name, for example:

```text
$pm-skill-demo:audit-authz
```

### Qwen Code installation

```bash
bash install-qwen.sh
```

This script:

1. Confirms the repo has a `qwen-extension.json` manifest.
2. Skips if the extension is already linked; otherwise calls `qwen extensions link` on the repo root.

Qwen Code loads the extension as a symlink, so subsequent file edits take effect after restarting Qwen Code — no script rerun needed unless the repo moved.

Invoke a slash command explicitly with its namespaced command name, for example:

```text
/pm-skill-demo:audit-authz
```

## Updating

Re-run the appropriate installer after editing the skill files or updating your working copy:

- Claude Code: re-run `bash install-claude.sh`, then run `/reload-plugins` in Claude Code.
- Codex: re-run `bash install-codex.sh`, then start a new conversation.
- Qwen Code: edit or update files freely and restart Qwen Code; rerun `bash install-qwen.sh` only if you moved the repo.

Plugin authors must bump the version in `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, and `qwen-extension.json` for every content change so each host reflects the new release.

### Privacy-first and local inference

While a subscription to a service like Claude Code or Codex is fairly inexpensive, it comes at a cost to privacy. This is a show-stopper for many people – usually for ideological, practical, contractual, or regulatory reasons.

The good news is that you don't have to use Big Tech to use these commands and skills, or generative AI in general. There are privacy-first options for both agentic harnesses, and inference. 

On the harness front (the AI coding assistant you interface with) you can always use a FOSS one like [opencode](https://github.com/anomalyco/opencode), [cline](https://github.com/cline/cline), [OpenHands](https://github.com/OpenHands/OpenHands), [crush](https://github.com/charmbracelet/crush), [Zoo Code](https://github.com/Zoo-Code-Org/Zoo-Code/), or [Qwen Code](https://github.com/QwenLM/qwen-code) to name but a few.

On the inference provider front, there are privacy-first inference providers with data sovereignty guarantees. I use [Scaleway's "Serverless" Generative APIs](https://www.scaleway.com/en/generative-apis/), but you should shop around, according to your needs. You can also run inference locally, using a suitably powerful GPU and software like LM Studio or Ollama. Everything will remain on your local network / computer, it will be much cheaper than purchasing inference services, but it will also be _slow_.

## Commands and skills

Claude Code exposes the following workflows as `/pm-skill-demo:<name>` slash commands. Codex exposes the same workflows as `$pm-skill-demo:<name>` skills. Qwen Code exposes them as `/pm-skill-demo:<name>` slash commands (same namespacing as Claude Code). All three have access to the skills using natural language prompts – this is where this plugin's power lies.

### `audit-authz`

Security check for the controllers of a Joomla! component. Ensures there's appropriate anti-CSRF and authorisation (not just authentication) checks throughout.

### `audit-code-execution`

Trace attacker-influenced data into server-side execution sinks: OS commands, dynamic PHP execution or inclusion, unsafe deserialisation, and attacker-selected callables or classes.

### `audit-controller-exposure`

Security check for Joomla! controllers covering what `audit-authz` and `audit-sql-filtering` don't: mismatched privilege checks (right kind of check, wrong permission/asset), backend-only tasks reachable from frontend/api controllers (or vice versa), and unsafe file uploads (allow-listing, predictable paths/names, execution in the storage location, path traversal).

### `audit-file-operations`

Audit attacker-influenced filesystem paths and archive entries for traversal, arbitrary file access or modification, dynamic inclusion, symlink escape, and Zip Slip.

### `audit-jexec`

Make sure the `defined('_JEXEC') || die;` line appears in every distributed file of a Joomla! extension. This excludes vendored dependencies.

### `audit-object-access`

Audit per-record and collection access outside the controller gate for IDOR/BOLA, ownership bypass, unsafe mass assignment, and cross-user or cross-tenant leakage.

### `audit-package-surface`

Inspect the actual release artifact for unintended files and entry points, unsafe installer or upgrade behaviour, unnecessary production code, and vulnerable locked dependencies.

### `audit-secrets-crypto`

Audit exposed credentials, predictable security tokens, password handling, signing and comparison flaws, cryptographic misuse, and key lifecycle.

### `audit-sensitive-output`

Audit non-HTML output sinks — response headers, downloads, CSV exports, logs, errors, outbound mail, and caches — for injection and unintended disclosure.

### `audit-sql-filtering`

Audit the component for unsafe validation/escaping of filter, user-state, and user-input values that end up in SQL queries (a source of blind SQL injection). Reports each location with a severity estimate and proposed mitigations for review.

### `audit-ssrf-redirects`

Audit attacker-influenced URL flows for server-side request forgery, redirect-based allow-list bypasses, credential forwarding, and open redirects.

### `audit-xss`

Trace attacker-influenced data into HTML, attributes, URLs, inline JavaScript, embedded JSON, rich text, and DOM insertion sinks to find reflected, stored, and DOM-based XSS.

### `e2e-tests`

Sets up (or expands/converts existing) PHPUnit unit tests and Docker-based E2E integration tests for Joomla or standalone PHP projects, including the version support matrix each targets.

### `en-gb-consistency`

Go through the English language strings to make sure they are consistently following British English spelling and grammar rules.

### `joomla-deprecations`

Addresses the latest batch of deprecations in core Joomla! based on the migration documentation found in the official Joomla! manual.

### `machine-translation`

Fills in the missing translations for a core collection of languages: Greek, French, German, Spanish, Italian, and Portuguese.

### `php-conservative`

Make sure the code is compatible with all PHP versions from the lowest declared in `composer.json` (or 7.4 if none is declared) up to and including the latest published stable version of PHP.

> [!IMPORTANT]
> This works best if you use bounded PHP version expressions in your `composer.json`, e.g. `"php": ">=8.1 <=8.6"`.

Driven directly by PHP_CodeSniffer with the PHPCompatibility standard, run against the range declared in `require.php`. It is read-only: it reports, it never rewrites.

We are explicitly *not* using Rector. Rector rewrites code *to* a target version, which raises the floor of a supported range instead of reporting on it, so it is the wrong shape for auditing a range.

### `php-upcoming`

Make sure the code is compatible with the upcoming, in-development version of PHP.

This is a separate skill from `php-conservative` because static analysis cannot answer the question: the compatibility sniffs have no data for a PHP version that has not shipped and report nothing for it — which is indistinguishable from a pass. So this skill runs the test suite on the upcoming PHP with `error_reporting = E_ALL` instead (`run.sh --deprecations`, for projects with the Dockerised integration harness) and reports the deprecations the run actually provoked from your own code.

### `plan-and-execute`

Give it an ambitious or complex task. It breaks the work into smaller, independently implementable steps, then uses the host's planning and delegation capabilities as appropriate to drive the implementation to completion.

> [!IMPORTANT]
> Add `/.plans` to your `.gitignore` file to avoid the transient plan files from being committed to your repository.

## License

MIT, see [LICENSE](LICENSE).
