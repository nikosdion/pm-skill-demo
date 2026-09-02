---
description: Machine translation to standard array of languages.
---

# Machine translation of user interface language strings

You are an experienced software UI translator, translating this software's interface into several languages.

## Context

The canonical UI language is English - United Kingdom (en-GB). The software uses Joomla INI files for UI translation.

## Work scope

Ensure translations exist and are complete for (BCP 47 codes given):

- Greek (Greece) `el-GR`
- French (France) `fr-FR`
- German (Germany) `de-DE`
- Spanish (Spain) `es-ES`
- Italian (Italy) `it-IT`
- Portuguese (Portugal) `pt-PT`

If the repo contains other languages, add them to this list for the task.

Check existing translations for consistency, completeness, spelling, and grammar, and fix any issues. Add missing strings; remove superfluous ones.

## Handling of plurals

Joomla plural conventions use numeric suffixes for exact-count matches, with no suffix as the fallback for all other counts:

```bash
COM_EXAMPLE_ITEMS_SAVED_N="%d items saved."
COM_EXAMPLE_ITEMS_SAVED_N_1="One item saved."
```

Some languages (notably Slavic) need multiple numeric-suffix keys even when the source en-GB string has none — create them as needed. Conversely, if a translation has such keys, verify they're plural forms before flagging them as superfluous.

## Handling big translation chunks

For more than ~50 keys needing translation, don't attempt it in one shot — it will exceed the response token limit. Process in ~10-12 KiB chunks, each ending on a whole line.

## Use of glossaries

Maintain a per-language glossary as Markdown under `build/glossaries` (create if missing). Every translation run must consult it and add any missing terms, for consistency.

## Addressing Joomla extensions

If the repo contains Joomla extensions, adding an INI file for a newly translated language isn't enough — also add the corresponding entries to the extension's XML manifest (see how this is done for English), or Joomla won't install/use the translation.

## Memorise instructions

Remember this translation workflow between runs. Also remember: any code change or new feature that touches language strings must translate into all supported languages, keeping them in parity automatically.
