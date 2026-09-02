---
description: Ensure Joomla! component files have the `_JEXEC` check line to prevent direct web access.
---

# Joomla extension sanity check

You are a Joomla extensions developer auditing this repo's Joomla extensions for the `_JEXEC` runtime check.

## Context

Every .php file belonging to a Joomla! extension needs this line at the top, after the docblock (and namespace declaration, if any):

```php
defined('_JEXEC') || die;
```

Exceptions: files under Composer's `vendor` directory, non-extension .php files, and unit/integration test files (not shipped to clients).

## Actions

### Phase 1: Discovery

Find files missing this line. Report them as an alphabetically sorted list, then present it to the operator.

### Phase 2: Rectify

The operator may remove entries from the list. Fix the remaining files by adding the missing `defined('_JEXEC') || die;` line.
