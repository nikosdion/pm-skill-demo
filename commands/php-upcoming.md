---
description: Address compatibility with upcoming versions of PHP
---

# Address upcoming PHP version compatibility

You are an expert PHP developer, working diligently to proactively address deprecations in the upcoming PHP version affecting your software.

## Context

This working copy is written primarily in PHP. We're preparing for the upcoming PHP version — found at the top of https://php.watch/versions, which links to pages covering its new and modified behaviour.

## No deprecation warnings goal

The software must run without warnings/notices from deprecated or obsolete PHP features, across the entire supported PHP version range — including the upcoming version.

## Static analysis cannot do this job

Start from this, because it determines the whole approach:

**The compatibility sniffs have no data for a PHP version that has not been released.** PHPCompatibility gains support for a version some time *after* it ships. Worse, it does not validate `testVersion` — ask it about a version it knows nothing about and it reports nothing at all, which is indistinguishable from a pass.

So the PHPCompatibility sweep (see `/php-conservative`) cannot answer this question, and a clean run from it is not evidence of anything here. If its `testVersion` range had to be clamped below the installed PHPCompatibility release's data ceiling, that clamp names exactly the versions it could not check — those are the versions this workflow is about.

Rector cannot answer it either; it rewrites code *to* a target version, breaking the bottom of the supported range rather than reporting on it. Ignore any `rector.yaml` in the repository.

**Executing the code on the upcoming PHP is the only real check.** Everything below follows from that.

## Actions

### Step 1: Identify the target version and the gap

Determine the upcoming PHP version from https://php.watch/versions, and the maximum version the project declares in `composer.json` (`require.php`).

Run the PHPCompatibility sweep once to check the installed release's sniff data ceiling: it names the versions static analysis cannot reach. Confirm the upcoming version is among them. If the sniffs *have* since gained support for it, say so — the job is then largely `/php-conservative`'s.

### Step 2: Run the test suite on the upcoming PHP

For a project with the Dockerised integration harness (`tests/integration/docker/`):

```
tests/integration/docker/run.sh --deprecations
```

This provisions the usual site on the image named by `PHP_DEPRECATIONS_VERSION` in `docker/.env` (use the `-rc` image tag while the version is in development), runs the whole suite with `error_reporting = E_ALL`, and reports every deprecation, notice and warning the run provoked **from our own code**. Any such line fails the run: a suite that passes while emitting deprecations has not demonstrated compatibility.

If `PHP_DEPRECATIONS_VERSION` still names an older version than the one you are targeting, update it.

For a project without that harness, run whatever suite it does have on an upcoming-PHP container with `error_reporting = E_ALL` and `log_errors = On`, and read the log.

Two things routinely go wrong here, and both make a run look clean when it is not:

- **The site's `php.ini` may silence `E_DEPRECATED` on purpose**, so that notices do not leak into response bodies and break tests asserting on what the browser received. Do not simply turn `display_errors` on — that breaks the suite. Route diagnostics to a log file outside the web root instead.
- **A pre-release PHP image may be broken in ways unrelated to our code** — a missing shared library making an extension fail to load, for instance, which then emits a startup warning on every request straight into the log you are trying to read. Fix the image before trusting the log.

### Step 3: Filter the results to our own code

A pre-release PHP makes the framework and its bundled dependencies emit enormous numbers of diagnostics — tens of thousands of lines is normal. Those are real, but they are not ours to fix, and reporting them buries the handful that are. Filter to paths inside our own extension or application, and keep the unfiltered log for reference.

### Step 4: Cover what the suite does not exercise

A test suite only reports deprecations on code paths it actually runs. Read the upcoming version's deprecation and RFC list on php.watch, and check the codebase for the ones that would not surface in a test run — code behind rarely-taken branches, admin-only features, error handlers, CLI commands.

Where a fix would break an already-supported version, gate it on the `PHP_VERSION_ID` constant; if that is not possible, flag it for manual review.

### Step 5: Feedback round

The operator is a subject matter expert who will evaluate findings and give further guidance.

### Step 6: Plan fixes

Once the operator is done giving feedback, check for remaining items to fix.

If none, say so and stop.

Otherwise, break the fixes into smaller, individually implementable plans and write them to the .gitignore'd `.plans` directory (clearing any existing files there first). Then propose running those plans in parallel via subagents/workflows, using the cheaper Sonnet model since the planning work is already done.

Re-run the suite on the upcoming PHP after the fixes land, and report the result. A run which reports nothing from our own code is the only thing that closes this out.
