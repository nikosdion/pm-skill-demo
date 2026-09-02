---
name: plan-and-execute
description: Break an ambitious or complex implementation request into independently executable steps, then carry the plan through to verified completion. Use when the user explicitly asks to plan and execute a substantial task.
---

# Plan and execute a complex task

Treat the remainder of the invoking prompt as the task.

1. Inspect the repository and its instructions enough to form an evidence-based plan.
2. Split the work into independently implementable steps and record them with Codex's plan mechanism. Keep at most one local step in progress at a time.
3. Execute the plan through completion. Delegate independent, bounded steps to subagents when useful and safe; otherwise work locally. Do not delegate steps whose concurrent edits would overlap.
4. Integrate all results, run proportionate verification, and resolve failures before reporting completion.

Do not stop after planning unless execution needs authority or information only the user can provide. Preserve existing user changes and obey all repository instructions.
