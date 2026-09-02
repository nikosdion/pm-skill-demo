---
name: audit-controller-exposure
description: Audit Joomla controllers for mismatched privilege checks, backend-only tasks leaking into frontend/api, and unsafe file uploads. Cross-references audit-authz for missing auth/CSRF checks and audit-sql-filtering for SQL injection — use those for that ground. Use when reviewing controller privilege scope or upload handling, or when explicitly invoked for this audit.
---

# Audit Joomla controller exposure

Read [the shared audit workflow](../../commands/audit-controller-exposure.md) completely, then follow it for the current repository. Treat references to the operator as references to the user.
