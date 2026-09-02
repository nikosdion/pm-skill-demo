---
name: e2e-tests
description: Implement Unit Tests using PHPUnit and E2E Integration Tests using Docker for Joomla extensions and standalone PHP projects.
---

# Unit and end-to-end tests

Two distinct layers, never conflated:

- **Unit tests** — PHPUnit, in-process, no I/O. Exercise helpers, models and other classes that can
  reasonably run in isolation.
- **E2E integration tests** — PHPUnit running on the *host*, driving a real, disposable Joomla or
  standalone stack in Docker over real HTTP. Nothing boots the application in-process; the suite
  observes it exactly as a browser (or an attacker) would.

If either layer already exists, evaluate it against this skill first. Expand what already follows the
pattern; convert what doesn't. Don't discard working tests to rewrite them from scratch — port their
assertions, don't just delete and start over.

## Step 0 — establish the target

Before writing anything, determine:

1. **Software type** — Joomla extension or standalone PHP. Usually obvious from the manifest
   (`*.xml` with `<extension>`, or `composer.json` alone).
2. **Supported PHP range** — read `composer.json` → `require.php` (or `config.platform.php`). The
   *maximum* satisfying version is the unit test target. The *minimum* is the floor of the E2E PHP
   matrix.
3. **Supported Joomla range**, if applicable: the installer's declared minimum (e.g.
   `$minimumJoomla` in `script.<element>.php`, or the manifest's minimum-Joomla tag) is the matrix
   floor. The latest stable release is the day-to-day version and the matrix ceiling.

Don't guess the matrix — derive it from what the project actually declares, and write down where you
got each bound.

Matrices go stale the moment a new PHP/Joomla release ships or the project's own declared floor
moves. Re-check and realign it periodically rather than hand-editing version numbers piecemeal.

## Unit tests

- PHPUnit must be installed **globally via Composer on the host** — `composer global require
  phpunit/phpunit` — never as a project dependency. Never add `phpunit/phpunit` to the project's
  `composer.json` or run it through `vendor/bin/phpunit`. Run it as the bare `phpunit` command
  (confirm it resolves on `PATH`; global Composer bin dirs are often missing from `PATH` and need
  adding).
- Target PHP version = the maximum version satisfying the project's `require.php` constraint. Don't
  test against a PHP version the project doesn't claim to support.
- A `phpunit.xml` at the project root, bootstrapping only what's needed to load the classes under
  test (e.g. an autoloader), not the full application. `<source><include>` should point at the
  specific directories under test (helpers, models), not the whole codebase — coverage numbers over
  framework glue code you can't unit test anyway are noise.
- Test only what's reasonably testable in isolation: pure helpers, models with injectable
  dependencies, value objects, formatters. Don't force framework-coupled classes (controllers, MVC
  views, anything that needs a booted CMS) into unit tests — that's what E2E is for.
- If unit tests already exist, run them, read what they cover, and extend coverage for
  the code you're touching rather than restructuring what already works.

## E2E tests — shared architecture across all three platforms

Model this on a self-contained `tests/integration/` (or `tests/e2e/`) directory:

```
tests/integration/
  docker/
    docker-compose.yml     # services only; never composed or run by hand
    Dockerfile.<service>    # one per built image (php, web, web-nginx, ...)
    env.dist                 # committed template; run.sh copies it to .env on first run
    run.sh                   # the one-shot orchestrator — see below
    config/                  # vhost configs, php.ini overrides, etc.
  src/
    Engine/                  # host-side HTTP client, DB access, session helpers
    Tests/                   # the actual PHPUnit test classes
    AbstractE2ETestCase.php  # base class: logged-in actors, refusal/assertion helpers
  bootstrap-e2e.php          # tiny: registers the autoloader, probes the site is reachable
  config.dist.php            # committed defaults; config.php is generated, git-ignored
  README.md                  # requirements, quick start, options, matrix rationale
phpunit-integration.xml      # separate from the unit phpunit.xml; bootstrap = bootstrap-e2e.php
```

`run.sh` is the only supported entry point and must, in order: scrub any previous stack/volumes to a
clean slate, build and bring the Docker services up, install/configure the target software, provision
whatever fixtures the tests need, run PHPUnit, then tear the stack down (unless told to keep it). A
run that fails or crashes partway must never leave a stack behind in an unknown state — scrub on both
entry and explicit `--down`, not just on success.

Required `run.sh` options: an override for the CMS/PHP version under test, `--matrix` to iterate the
full version matrix, `--filter` passed through to PHPUnit, `--skip-build` to reuse an already-built
package, `--keep-containers` to leave the stack up for fast iteration (provisioning is the slow part;
re-running PHPUnit against a kept-up stack should take seconds), `--down` to tear down and exit, and
`--no-tests` to provision without running the suite.

`bootstrap-e2e.php` loads no application code and opens no direct database connection — it registers
the suite's autoloader and curl-probes the site, failing with a clear "run `docker/run.sh` first"
message instead of a wall of connection-refused errors when someone runs `phpunit` without
provisioning first.

Write a `README.md` in the integration test directory covering: requirements (Docker, host PHPUnit,
any build tool needed to produce an installable package), quick start, the `run.sh` options table,
and — critically — **why the version matrix contains the versions it does**, tied to specific
version-gated code paths where possible. A green single-version run proves less than it looks; say so
if that's the situation.

## Joomla specifics

- Docker services: `db` (MySQL), `php` (PHP-FPM running Joomla + the Joomla CLI), `web` (Apache,
  proxying to `php` over FastCGI). Add `web-nginx` only if the project has server-specific behavior
  worth exercising twice (e.g. `.htaccess`-based access control that NginX doesn't honor) — don't add
  it by default. **Never use IIS**, even though Joomla supports it; it doesn't fit the Docker-based,
  cross-platform CI model this skill targets.
- Install Joomla via its own `installation/joomla.php` CLI installer inside the `php` container, not
  by hand-seeding the database.
- Day-to-day runs (no flags) target the latest supported Joomla release and the latest PHP version
  compatible with it. `--matrix` iterates a documented list of versions — including any interior
  version whose absence would make the matrix meaningless (see the README requirement above).
- Enforce the installer's declared minimum version before touching Docker at all — read it from the
  same file the installer itself reads (`script.<element>.php` or the manifest), so the two can't
  drift apart.
- If the project sends mail, add a Mailpit service (SMTP sink, inspectable over its REST API) rather
  than stubbing the mailer — this exercises the real mailer configuration end to end. Add an IMAP/POP3
  source (e.g. GreenMail, no published ports, driven only from inside the compose network) only if the
  project actually fetches mail.

## Standalone (no CMS) specifics

- Docker services: just `php` (CLI or built-in server, whichever the software actually needs to run
  under) plus any real dependency it talks to (a database, a queue, an external-service double) —
  never mock what Docker can run for real.
- No CMS install/provisioning step; "provisioning" here just means getting the software's own
  fixtures/config into place.
- Day-to-day default is the single latest supported PHP version. `--matrix` covers the full range from
  the lowest to the highest PHP version declared in `composer.json`.

## Writing and converting tests

- Each test class lives under `src/Tests/`, extends the shared base test case, and drives the site
  through the host-side HTTP client — never through direct database writes for the behavior under
  test (fixtures/setup are the one exception).
- When a request should be refused, assert both the refusal *and* the absence of its effect (the
  state change didn't happen) — a rejected message is easy to fake, a row that wasn't written isn't.
- Where a refusal's evidence lives in session state (a flash message, a redirect target), assert it
  against the actor whose session it belongs to, not a fresh, unrelated client.
- Before trusting a new "must be refused" test, confirm it can actually fail — point it at a
  legitimate variant of the same request and check the assertion would catch a missing guard, not
  just a syntactically-different one.
- When behavior looks like a genuine product bug rather than a test-writing mistake, skip the test
  with a clear diagnosis and raise it — don't assert today's buggy behavior as correct just to get a
  green suite.
- When converting an existing E2E suite that boots the CMS in-process (rather than testing over real
  HTTP against a Docker stack): keep its test *intent* and assertions, rewrite the *mechanism* to go
  through the shared architecture above. In-process harnesses can't observe anything a real request
  couldn't, and asserting on internals only reachable in-process is coverage that doesn't reflect
  reality.

## Safety

- `run.sh` (or equivalent) must default to tearing the stack down after a run and must always scrub
  before starting — a previous crashed run must never leak into the next one.
- Nothing in this skill's Docker services should ever be pointed at a non-disposable database or a
  real mail server. Ports and container names should avoid colliding with any other local dev stack
  the project already uses (check for one before picking defaults).
