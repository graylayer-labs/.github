# Quality Gate

PRs in graylayer-labs are merged without a human reviewer, so two required checks have to be enough on their own. Both are mechanical; there is no AI review. Agents use the owner's GitHub identity, so a review approval cannot be used as a gate.

## Required checks on main (public repos)

| Check | Where it is defined | What it does |
|---|---|---|
| `checks / checks` | This repo's `ci-python.yml`, `ci-node.yml` or `ci-lint.yml`, called by each repo's `.github/workflows/ci.yml` (see `docs/reusable-ci.md`) | Lint, format, types and tests, all strict. Python repos also fail when under 80% of the lines a PR changes are covered (diff-cover). |
| `gate / gate` | This repo's `.github/workflows/org-gate.yml`, called by each repo's `.github/workflows/gate.yml` | PR rules below, plus dependency review. |

Private repos (edge-vla, gnn-drag-surrogate, repo-template) have no branch protection on the free plan; their checks run but are not enforced.

## What `gate` fails on

- The title is not `<type>(<scope>): <summary>` with type `feat`, `fix`, `refactor`, `test`, `docs` or `chore`, no full stop, and short enough that the squash subject (title plus ` (#N)`) fits 72 characters.
- The body has no `Closes #N` or `Fixes #N`. Dependabot PRs are exempt.
- More than 400 lines change, not counting lockfiles (`uv.lock`, `package-lock.json` and similar). Split the PR.
- The PR touches a protected path: `.github/workflows/**` (which includes the gate, its callers and `ci.yml`) or any `CODEOWNERS`. Dependabot action bumps pass when every commit is Dependabot's own and signed by GitHub.
- `actions/dependency-review-action` finds a dependency with a high or critical advisory. Public repos only: private repos on the free plan have no dependency graph, so the step is skipped there.

Callers run on `pull_request_target`, so a PR is judged by the gate as it is on the base branch. A PR cannot weaken the gate or `ci.yml` and have the weaker version judge it. The gate reads PR metadata through the API and never checks out PR code.

## Protected paths and the owner's merge

A PR that fails `gate` never auto-merges. This covers every change to workflows and CODEOWNERS. The owner reviews it and merges it by hand, using the bypass on the repo's `gate` ruleset (the "Merge without waiting for requirements" option). `checks / checks` stays in classic branch protection with admins included, so the bypass skips `gate` only.

The bypass is open to the owner's identity, and agents use that identity, so GitHub cannot stop an agent from using it. The rule is therefore a process rule: agents never merge with `--admin` or any bypass, and every bypass merge shows in the ruleset's insights. A GitHub-enforced owner-only path needs agents on their own identity (a GitHub App or machine user); then CODEOWNERS with required review would do it.

## Auto-merge

A repo allows auto-merge (squash) only when its `checks` runs lint, format, types and tests, all strict, with no `|| true` or exit-zero escapes. Eligible repos also run `dependabot-automerge.yml`, which turns on auto-merge for minor and patch Dependabot PRs; GitHub merges them once both checks are green.

## Coverage exceptions

| Repo | Exception | Reason |
|---|---|---|
| `rl-core` | diff-cover excludes `rl_core/reproductions/*/runner.py`, `*/preflight.py` and `reproductions/__main__.py` | They drive ALE emulators and ROMs, which CI does not install (the `atari` group is optional by design). |

## Steps turned off

A repo may turn off a `ci-python.yml` step only with a tracked issue that turns it back on. Such a repo is not eligible for auto-merge.

| Repo | Off | Issue |
|---|---|---|
| `rl-evo-lab` | ruff, format, ty | rl-evo-lab#5 |
| `lang-goal-rl` | ruff, format, ty | lang-goal-rl#3 |
| `gnn-drag-surrogate` | ty | gnn-drag-surrogate#3 |

## Before pushing

```bash
uv sync
uv run ruff check . && uv run ruff format --check .
uv run ty check --error-on-warning
uv run pytest
```
