---
description: Break a long task into an implementable multi-step plan, then execute it via worktrees/subagents/workflows on the cheaper model.
model: opus
---

# Plan and execute a long task

## Task

$ARGUMENTS

## Actions

### Step 1: Plan

Split the task above into multiple, individually implementable steps. Write each step as a Markdown file in the .gitignore'd `.plans` directory under the working copy's root. If that directory already exists, empty it first, then recreate it.

### Step 2: Execute

Implement the plans, using worktrees, subagents, and workflows as deemed necessary. Use the cheaper Sonnet model at medium effort — the planning already did the hard thinking, so a smarter but pricier model isn't needed.

If automatically switching to an execution context isn't possible, present the prompt I should paste into a new session to start the implementation run instead.
