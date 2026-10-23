# Auto-merge in graylayer-labs

PRs merge without a human reviewer, so auto-merge rests on two required checks on each public repo's `main`. The rules are in [`.claude/rules/quality-gate.md`](../.claude/rules/quality-gate.md); this page says what runs where.

## What runs

| Check | Defined in | Called from |
|---|---|---|
| `checks / checks` | `.github/workflows/ci-python.yml`, `ci-node.yml` or `ci-lint.yml` here ([reusable CI](reusable-ci.md)) | each repo's `.github/workflows/ci.yml` |
| `gate / gate` | `.github/workflows/org-gate.yml` here | each repo's `.github/workflows/gate.yml`, on `pull_request_target` |

`checks / checks` is required by classic branch protection (admins included). `gate / gate` is required by a repo ruleset named `gate`, whose bypass the owner uses to merge PRs that touch protected paths.

## What auto-merges

- Only on repos whose `checks` runs lint, format, types and tests, all strict. Today: rl-core, llm-post-training-lab, aerial-search-lab.
- On those repos `dependabot-automerge.yml` turns on squash auto-merge for minor and patch Dependabot updates; GitHub merges them once both checks are green.
- Any other PR is merged by the agent that owns it (squash, branch deleted) after both checks pass and its self-review is clean.
- PRs that change `.github/workflows/**` or `CODEOWNERS` fail `gate` and are merged by the owner by hand.

Private repos (edge-vla, gnn-drag-surrogate, repo-template) have no branch protection on the free plan; their checks run but nothing is enforced and nothing auto-merges.

## Retired

The label-driven system that used to live here (`code-quality.yml`, `monitor-org-prs.yml`, `quality-gate.yml`, `ruff.yml`, `pyright.yml`) was removed in October 2026, together with `sync-org-standards.yml`, which pushed copies of those standards into each repo and had been failing on every run.
