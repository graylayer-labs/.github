# Auto-Merge System for graylayer-labs

Fully automated org-wide code quality and standardization system.

## How It Works (No Manual Steps Required)

### 1. Sync Workflow (`sync-org-standards.yml`)

**Runs:** Every Monday at 9 AM UTC (or manual trigger)

**Does:**
- Checks all 5 Python repos (lang-goal-rl, ssl-aerial-person-detection, rl-evo-lab, model-monitor-custom, rl-core)
- For each repo:
  - Clones and checks if standardization is needed
  - Creates `chore/org-standards-sync` branch if code-quality workflow missing
  - Adds/updates:
    - `.github/workflows/code-quality.yml` (language detection + auto-merge)
    - `ruff.toml` extension in `pyproject.toml`
    - `.claude/CLAUDE.md` referencing org rules
  - Pushes branch and creates PR
  - Labels PR with `type:chore` and `auto-merge`

### 2. Code Quality Workflow (`code-quality.yml`)

**Runs:** On every PR (in all repos)

**Detects languages:**
- Python (`pyproject.toml`) → ruff check/format + ty + pytest
- JavaScript (`package.json`) → npm lint + npm test  
- Go (`go.mod`) → golangci-lint + go test

**Auto-merges when:**
- All language checks pass
- PR has `auto-merge` label
- PR is not a draft
- Squash merges and deletes branch

### 3. Monitor Workflow (`monitor-org-prs.yml`)

**Runs:** Every 30 minutes

**Does:**
- Finds all open PRs with `auto-merge` label across all 5 repos
- Checks if all CI checks have passed
- Enables auto-merge on PRs ready to merge
- Cleans up branches from merged PRs

## Current Status

✅ **System is self-contained** — everything runs in `.github` repo via workflows
✅ **No manual PRs needed** — sync workflow creates them automatically  
✅ **Automatic merging** — monitor workflow handles auto-merge + cleanup
✅ **Scheduled runs** — sync weekly, monitor every 30 min

## What You Do

**Nothing!** The system runs automatically.

**To manually trigger sync:**
```bash
gh workflow run sync-org-standards.yml --repo graylayer-labs/.github
```

**To check status:**
- Sync status: https://github.com/graylayer-labs/.github/actions/workflows/sync-org-standards.yml
- Monitor status: https://github.com/graylayer-labs/.github/actions/workflows/monitor-org-prs.yml
- Org PRs: https://github.com/graylayer-labs/pulls?q=label:auto-merge

## What Gets Synced to Each Repo

### 1. Code Quality Workflow

```yaml
.github/workflows/code-quality.yml
```

Language-aware workflow that:
- Detects Python/JavaScript/Go
- Runs appropriate linters and tests
- Auto-merges when all pass + has `auto-merge` label

### 2. Ruff Configuration

In each repo's `pyproject.toml`:
```toml
[tool.ruff]
extend-config = ["https://raw.githubusercontent.com/graylayer-labs/.github/main/ruff.toml"]
target-version = "py311"
```

Extends org-wide ruff config, can override per-repo if needed.

### 3. Claude Configuration

```
.claude/CLAUDE.md
```

References org-level rules:
```markdown
# Project Configuration

See [graylayer-labs/.github](https://github.com/graylayer-labs/.github) for org-level standards.

## Imports

@graylayer-labs/.github/.claude/CLAUDE.md
```

## Label Schema

All repos use standardized labels from `.codex/label-schema.yaml`:

**Required (per repo):**
- `data:*` — Dataset (e.g., `data:COCO/Detection`)
- `model:*` — Algorithm (e.g., `model:YOLO/v8`)
- `status:*` — Maturity (e.g., `status:Experimental`)
- `source:*` — Framework (e.g., `source:PyTorch`)

**Optional (issues/PRs):**
- `type:*` — Type (bug, enhancement, documentation, experiment)

Labels already synced to all repos. Use them consistently.

## Files in `.github`

```
.github/
├── .github/workflows/
│   ├── code-quality.yml          ← Runs in all synced repos
│   ├── sync-org-standards.yml    ← Creates/updates org sync PRs (weekly)
│   ├── monitor-org-prs.yml       ← Monitors & auto-merges PRs (every 30 min)
│   ├── quality-gate.yml          ← Deprecated (kept for reference)
│   ├── ruff.yml                  ← Deprecated
│   └── pyright.yml               ← Deprecated
├── ruff.toml                     ← Org-wide ruff config
├── scripts/
│   └── label-sync.sh             ← Manual label syncing (if needed)
├── docs/
│   ├── AUTO-MERGE-SYSTEM.md      ← This file
│   └── new-repo-setup.md         ← Template for new projects
├── .claude/
│   └── rules/
│       ├── quality-gate.md       ← How repos set up quality gate
│       ├── labeling.md           ← Label conventions
│       └── python.md             ← Python tooling rules
└── .codex/
    └── label-schema.yaml         ← Complete label definitions
```

## Troubleshooting

### PR not auto-merging

**Check:**
1. PR has `auto-merge` label? (sync workflow adds it, but verify)
2. All CI checks passed? Check PR checks section
3. PR is not a draft?

**If ruff failed:**
- Fix locally: `uv run ruff check --fix && uv run ruff format`
- Push to sync branch, PR auto-updates
- Workflow re-runs

**If type check failed:**
- Fix locally: `uv run ty .`
- Push, workflow re-runs

**If test failed:**
- Fix locally: `uv run pytest tests/`
- Push, workflow re-runs

### Sync workflow not creating PR

**Check:**
1. Sync workflow run: https://github.com/graylayer-labs/.github/actions/workflows/sync-org-standards.yml
2. Look for errors in workflow logs
3. Repo might already have code-quality.yml (skips sync)

### Monitor workflow not merging ready PRs

**Check:**
1. Monitor workflow run: https://github.com/graylayer-labs/.github/actions/workflows/monitor-org-prs.yml
2. PR status checks: all green?
3. PR has `auto-merge` label?

## Future

- [ ] Extend to support Rust, C/C++, etc.
- [ ] Label validation in code-quality workflow (enforce labels on all PRs)
- [ ] Dependency scanning and updates
- [ ] Automated changelog generation
- [ ] Coverage reporting integration

## Reference

- [`.github/workflows/code-quality.yml`](.github/workflows/code-quality.yml) — Main quality workflow
- [`.github/workflows/sync-org-standards.yml`](.github/workflows/sync-org-standards.yml) — Sync automation
- [`.github/workflows/monitor-org-prs.yml`](.github/workflows/monitor-org-prs.yml) — PR monitoring
- [`.codex/label-schema.yaml`](.codex/label-schema.yaml) — Label definitions
- [`.claude/rules/`](.claude/rules/) — Org standards & rules
