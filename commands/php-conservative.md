---
description: Address compatibility with stable versions of PHP
---

# Address stable PHP compatibility

You are an expert PHP developer, working diligently to make your software compatible with stable PHP versions.

## Context

This working copy is written primarily in PHP. PHP compatibility constraints live in the root `composer.json` (`require.php`); if absent, assume a minimum of PHP 7.4.

## No deprecation warnings goal

The software must run without warnings/notices from deprecated or obsolete PHP features, across the entire supported PHP version range.

## Do not use Rector for this

Rector rewrites code *to* a target version. Its suggestions raise the floor — they break the bottom of a supported range rather than reporting on it — so it is the wrong shape for auditing a *range*. Several repositories still carry a years-old `rector.yaml`; ignore it. Do not propose running Rector, and do not spend the operator's time re-deriving this conclusion.

The tool for this job is PHPCompatibility, described below. It is token-based, so it needs no autoloading, no bootstrap and no CMS installation, and it takes seconds rather than minutes.

## Actions

### Step 1: Determine a realistic PHP version range

If `composer.json` exists, ensure the minimum supported version is at least 7.4 (flag and propose raising it otherwise), and the maximum is at least the latest published PHP version per https://www.php.net/supported-versions.php.

If dependencies force a narrower window, document and explain the options. Ideally we support every PHP version currently supported by the PHP project itself.

Derive the `testVersion` range passed to PHPCompatibility from `require.php` — never guess or hard-code it, so the range checked always matches the range the project actually claims.

### Step 2: Run PHP_CodeSniffer with the PHPCompatibility standard

Use PHP_CodeSniffer with the PHPCompatibility standard (`phpcompatibility/php-compatibility`
**10.0.0-alpha2 or later** — the 9.3.5 release is from 2019 and knows nothing past PHP 7.4, so it
reports almost nothing and that reads exactly like a pass):

```
phpcs --standard=PHPCompatibility --runtime-set testVersion <min>-<max> .
```

with `<min>-<max>` derived from `require.php`. Everything this does is read-only. Run `phpcs`, never
`phpcbf`, and pass no `--fix`.

Determine the highest PHP version the installed PHPCompatibility release actually has sniff data for
before trusting a run against a newer ceiling — check its changelog/releases if unsure.

### Step 3: Read the ceiling warning before trusting a clean report

PHPCompatibility does not validate `testVersion`. Ask it about a PHP version it has no data for and it reports **nothing at all**, which is indistinguishable from a clean bill of health. If the declared `<max>` is above the highest version the installed PHPCompatibility release has data for, clamp the `testVersion` range to that ceiling and say so plainly in your findings.

If you had to clamp, say so plainly in your findings: those versions are **unchecked**, not clean. Covering them is the job of `/php-upcoming`, which runs the test suite on that PHP instead. Never report "compatible with PHP X" on the strength of a static sweep that was clamped below X.

### Step 4: Triage the findings

Not every finding is a bug. Sort them into three piles, and say which pile each went in:

- **Genuine problems.** Fix them.
- **Deliberate behaviour the sniff cannot know about.** A check whose whole purpose is to detect a removed feature will be flagged for using it. Do not delete such a check to silence the sniff — that changes behaviour. Add a `phpcs:ignore <sniff code>` with a comment explaining why the code is correct as written, aimed at the next person tempted to "fix" it.
- **Provided by a polyfill.** Joomla! ships Symfony polyfills, so PHP 8.0/8.1 symbols are available on every supported Joomla! version. If PHPCompatibility flags a polyfilled symbol on a Joomla! extension, suppress that specific finding with a `phpcs:ignore` comment naming the polyfill, rather than treating it as a genuine problem. Do not apply that suppression to a standalone or CLI project — nothing polyfills those symbols there, and hiding the finding would hide real breakage.

Where a genuine fix would break an already-supported version, gate it on the `PHP_VERSION_ID` constant; if that is not possible, flag it for manual review.

### Step 5: Record a baseline only if the operator asks

`phpcs` supports `--report=json` output; if the operator wants to adopt this sweep in a repository with a large known backlog, save that JSON as a baseline file and diff later runs against it so they report only what's new. It is not a way to make a report go away, and the baseline is meant to shrink over time — never grow. Do not create one on your own initiative.

### Step 6: Feedback round

The operator is a subject matter expert who will evaluate findings and give further guidance.

### Step 7: Plan fixes

Once the operator is done giving feedback, check for remaining items to fix.

If none, say so and stop.

Otherwise, break the fixes into smaller, individually implementable plans and write them to the .gitignore'd `.plans` directory (clearing any existing files there first). Then propose running those plans in parallel via subagents/workflows, using the cheaper Sonnet model since the planning work is already done.

Re-run the `phpcs` sweep after the fixes land, and report the before/after counts.
