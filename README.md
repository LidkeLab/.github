# .github

LidkeLab organization defaults, and the lab's shared Julia CI workflow.

Every lab Julia package, in LidkeLab, JuliaSMLM or a personal account, runs its CI through one
reusable workflow kept here, `.github/workflows/julia-ci.yml`. Each package carries only a short
caller, the same in every package except its `with:` lines. This repository is public because a
reusable workflow in a private repository can be called only from private repositories in the
same organization. It holds no secrets.

## What the workflow runs

GitHub-hosted CI checks that a package installs and works on a clean machine. Correctness tests
that need a GPU, lab data, long run times or an instrument run on a lab machine instead.

| Job | When | What |
|---|---|---|
| `test` | always | `GROUP=Core` tests at Julia `min` (the `julia` compat lower bound) and `1`; a private repository runs `1` only |
| `qa` | always | `GROUP=QA` tests (Aqua, ExplicitImports) at Julia `1` |
| `downgrade` | `registered: true`, public repositories | `GROUP=Core` at Julia `min`, the oldest supported Julia, with direct dependencies at the lowest versions `[compat]` allows |
| `pre` | `registered: true`, public repositories, scheduled runs only | `GROUP=Core` at the Julia prerelease; allowed to fail |
| `format` | `runic: true` | Runic formatting check |

All jobs run on ubuntu-latest, x64, with a 60-minute timeout, and skip draft pull requests. There
is no coverage upload and no docs job. The `GROUP` variable is read by the lab's standard
`test/runtests.jl`, which runs the test groups declared in `test/test_groups.toml`.

## Inputs

| Input | Type | Default | Meaning |
|---|---|---|---|
| `registered` | boolean | `false` | The package is in the General registry: adds `downgrade` and the monthly `pre` run, in a public repository. |
| `runic` | boolean | `false` | Adds the Runic formatting check. Runic checks every `.jl` file in the repository. |
| `project` | string | `.` | Path to the package within the repository. |

## Adopting it in a package

1. Copy `templates/CI.yml` to `.github/workflows/CI.yml`. Change only the `with:` lines, for
   example `registered: true` for a registered package.
2. Copy `templates/dependabot.yml` to `.github/dependabot.yml` unchanged. Dependabot then opens a
   weekly pull request per dependency, covering Julia compat bounds in every environment of the
   repository and the GitHub Actions versions.
3. Delete `.github/workflows/CompatHelper.yml`, which Dependabot replaces, and the old CI workflow
   the caller replaces.
4. The package's tests must follow the lab's test layout: the standard `test/runtests.jl`, a
   `test/test_groups.toml`, and at least the `Core` and `QA` groups.

The caller runs on pushes to `main` or `master` and on tags, on pull requests (including when a
draft is marked ready), on manual dispatch, and monthly. Changes only to Markdown files, `dev/`
or `.claude/` do not start a run. A newer push to a pull request cancels the older run.

In a private repository, whose Actions minutes are paid, the jobs run only on pull requests and
manual dispatch and skip every other event (admiral decision 0025: the lab tests on its own
machines, and its local record checks the Julia floor). Public repositories run on every event.

A public repository saves its Julia cache only from the default branch, and pull requests restore
that cache. A private repository has no push runs, so every one of its runs saves: later runs on
the same pull request start warm, and a new pull request restores only the default branch's
cache, which a manual `workflow_dispatch` run on `main` seeds. GitHub drops a cache unused for 7
days, so the first run after a quiet week starts cold.

## Versions

Callers use `@v2`. The `v2` tag is moved forward only for backward-compatible changes: a new input
with a default that keeps the old behaviour, an updated action version, a fix. A change that could
turn a passing package red, or that removes or renames an input, is released as `v3`, and packages
move to it by editing their caller.

## Self-test

`.github/workflows/selftest.yml` runs the workflow from the same commit, with `registered` and
`runic` on, against a small fixture package in `test/fixture/FixturePkg`, on every push and pull
request.
