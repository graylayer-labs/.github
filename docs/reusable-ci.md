# Reusable CI

The org's CI lives here as reusable workflows (`workflow_call`). Each repo keeps two thin callers: `ci.yml`, which calls one of the workflows below, and `gate.yml`, which calls `org-gate.yml` (see `.claude/rules/quality-gate.md`).

| Workflow | Stack | What the `checks` job runs |
|---|---|---|
| `ci-python.yml` | Python with uv | `uv sync --dev --locked`, `ruff check`, `ruff format --check`, `ty check --error-on-warning`, `pytest` with pytest-cov, and on pull requests `diff-cover --fail-under=80` on changed lines |
| `ci-node.yml` | Astro on Node and npm | `npm ci`, `npm run check` (astro check), `npm run build` |
| `ci-lint.yml` | Workflows and shell | `actionlint` (with shellcheck on `run:` blocks) over `.github/workflows/`, `shellcheck` over scripts |

Tool versions (pytest-cov, diff-cover, actionlint, shellcheck) and action SHAs are pinned inside the workflows, so a bump here reaches every repo through one version bump.

## Calling a workflow

Name the caller job `checks`. The check then reports as `checks / checks`, which is the required check on public repos' main.

```yaml
name: ci

on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

jobs:
  checks:
    permissions:
      contents: read
    uses: graylayer-labs/.github/.github/workflows/ci-python.yml@<full sha> # v1.0.0
    with:
      coverage-source: my_package
```

Keep the `on:`, `permissions` and `concurrency` blocks in the caller; the called workflow sets none of them for the run.

## Inputs

### `ci-python.yml`

| Input | Default | Use |
|---|---|---|
| `python-version` | empty (project's `.python-version` or `requires-python`) | Python version for uv |
| `system-packages` | empty | Space-separated apt packages, e.g. `libosmesa6-dev libgl1 libglfw3` for MuJoCo |
| `env` | empty | Extra environment variables, one `NAME=value` per line, e.g. `MUJOCO_GL=osmesa`. `GITHUB_*`, `RUNNER_*`, `PATH`, `LD_*` and similar are refused. |
| `ruff`, `format`, `ty` | `true` | Turn a step off. Only with a tracked issue named in a comment beside it. |
| `ty-strict` | `true` | `false` runs `ty check` without `--error-on-warning` |
| `pytest-args` | empty | Extra pytest arguments, e.g. `tests/my_pkg -q` |
| `coverage-source` | `src` | What `--cov=` measures: a package name or a path |
| `coverage-omit` | empty | Space-separated globs that diff-cover excludes. Each one is a coverage exception and is recorded in `.claude/rules/quality-gate.md`. |
| `diff-cover-fail-under` | `80` | Minimum coverage of changed lines on PRs. `0` turns it off. |
| `timeout-minutes` | `30` | Job timeout |

### `ci-node.yml`

| Input | Default | Use |
|---|---|---|
| `node-version` | `22` | Node version |
| `check-script`, `build-script` | `check`, `build` | npm scripts to run; empty skips one |
| `build-with-token` | `false` | Pass the read-only `GITHUB_TOKEN` to the build, for sites that read repo data from the API |
| `timeout-minutes` | `15` | Job timeout |

### `ci-lint.yml`

| Input | Default | Use |
|---|---|---|
| `actionlint-skip` | empty | Space-separated workflow file names actionlint skips; give the reason in the caller |
| `actionlint-shellcheck` | `true` | Run shellcheck on `run:` blocks |
| `shellcheck-paths` | `scripts/*.sh` | Space-separated globs of scripts; empty skips the step |
| `shellcheck-severity` | `error` | Lowest severity that fails |
| `timeout-minutes` | `10` | Job timeout |

## Versioning

Callers pin a full commit SHA of this repo, with the release tag as a comment:

```yaml
uses: graylayer-labs/.github/.github/workflows/ci-python.yml@<full sha> # v1.0.0
```

- Releases are immutable tags `vMAJOR.MINOR.PATCH` on a commit of `main`. A tag is never moved or reused.
- PATCH: a fix that changes no input and no check outcome on green code. MINOR: a new input, or a new or stricter check that callers can turn off. MAJOR: an input removed or renamed, or a default made stricter with no way to opt out.
- Every repo's `dependabot.yml` already watches `github-actions` in `/`, which covers reusable workflow refs. Dependabot opens a PR that bumps the SHA and the comment when a new tag appears. Those PRs pass `gate` (Dependabot-only, GitHub-signed commits), so on repos with Dependabot auto-merge, minor and patch releases roll out once `checks` is green on the new version; majors wait for a manual merge.
- Workflows in this repo call each other by local path (`./.github/workflows/ci-lint.yml`), so a PR here is tested with its own changes.

Why not a moving `v1` tag: a moved tag changes what runs in every repo with no PR anywhere, which is the change the `gate` protected-path rule exists to stop. SHA pins keep each repo's CI change visible as a reviewed PR, and match how actions are pinned in the org.

### Cutting a release

After a PR that changes a reusable workflow merges:

```bash
gh release create vX.Y.Z -R graylayer-labs/.github --target <merge sha> --title vX.Y.Z --notes "<what changed for callers>"
```
