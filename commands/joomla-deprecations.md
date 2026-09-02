---
description: Address Joomla! code deprecations
---

# Address Joomla deprecations

You are an expert Joomla extensions developer, working diligently to proactively address deprecations in Joomla core code affecting your extensions.

## Context

This working copy contains Joomla extensions. We target compatibility with Joomla! 4.4+; if that range isn't feasible, we accept raising the floor to Joomla! 5.4 instead.

## Grounding on official sources

Source deprecations from the official Joomla Manual (https://github.com/joomla/Manual). Each version-family gap has a `new-deprecations.md` under `updates/<old><new>/` (version families without dots, e.g. deprecations between 4.0 and 4.1 are in `updates/40-41/new-deprecations.md`).

## Preserve the supported Joomla range

Prefer an implementation which works unchanged across the entire supported Joomla range. When a backwards-incompatible Joomla change requires separate code paths, prefer a capability check (such as `class_exists` or `method_exists`) over an explicit Joomla version check. Use a version check only when capability detection cannot reliably distinguish the required behaviour.

Immediately above every capability or version check used for this purpose, add a comment naming the Joomla version which introduced the backwards-incompatible change and briefly describing that change. This is required even when the condition appears self-explanatory: it lets maintainers find and remove the compatibility branch once the extension's minimum supported Joomla version moves past that release.

Do not adopt a newer API unconditionally when doing so would break an older supported Joomla version. If neither a shared implementation nor a gated compatibility branch is feasible, propose raising the compatibility floor and report it explicitly as required below.

## Actions

### Step 1: Reporting

Evaluate whether the extensions need work to address Joomla deprecations. If so, present a plan. If the compatibility floor needs raising, say so explicitly and upfront.

### Step 2: Feedback round

The operator is a subject matter expert who may ask you to reevaluate, reclassify, provide a handling approach, or overrule a finding after giving more context.

### Step 3: Plan fixes

Once the operator is done giving feedback, check for remaining items to fix.

If none, say so and stop.

Otherwise, break the fixes into smaller, individually implementable plans and write them to the .gitignore'd `.plans` directory (clearing any existing files there first). Then propose running those plans in parallel via subagents/workflows, using the cheaper Sonnet model since the planning work is already done.
