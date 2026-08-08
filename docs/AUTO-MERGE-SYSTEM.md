# Auto-Merge System for graylayer-labs

Complete system for org-wide code quality enforcement with automatic PR merging.

## Overview

The system has three components:

1. **Code Quality Workflow** — Language-aware CI that checks Python, JavaScript, Go
2. **Label Validation** — Ensures all PRs have required metadata labels
3. **Auto-Merge** — Automatically merges PRs when all checks pass

## Code Quality Workflow

**File:** `.github/workflows/code-quality.yml`

### How It Works

1. **Language Detection** (`detect-languages` job)
   - Scans for `pyproject.toml` → Python enabled
   - Scans for `package.json` → JavaScript enabled
   - Scans for `go.mod` → Go enabled

2. **Language-Specific Jobs** (matrix-like, but explicit)
   - **Python**: `uv sync` + `ruff check` + `ruff format --check` + `ty check`
   - **JavaScript**: `npm ci` + `npm lint` + `npm test`
   - **Go**: `golangci-lint` + `go test ./...`
   - Jobs only run if language is detected

3. **Label Validation** (`check-labels` job)
   - Verifies PR has required labels:
     - At least one `data:*` label
     - At least one `model:*` label
     - At least one `status:*` label
     - At least one `source:*` label

4. **Auto-Merge** (`auto-merge` job)
   - Runs only if:
     - All language checks passed (or were skipped)
     - Label validation passed
     - PR is not a draft
     - PR has the `auto-merge` label
   - Merges with `--squash`
   - Deletes feature branch

### Workflow Triggers

Runs on PRs that touch:
- Python files (`.py`)
- JavaScript/TypeScript files (`.js`, `.ts`, `.jsx`, `.tsx`)
- Go files (`.go`)
- Config files (`pyproject.toml`, `package.json`, `go.mod`, `ruff.toml`, `tsconfig.json`, `pyrightconfig.json`)
- The workflow itself

## PR Creation & Standardization

**Script:** `scripts/create-org-sync-prs.sh`

### What It Does

For each Python repo in the org:

1. **Clones the repo** (or pulls latest)
2. **Creates a feature branch** (`chore/org-standards-sync`)
3. **Adds code-quality workflow** to `.github/workflows/code-quality.yml`
4. **Updates pyproject.toml** to extend org ruff config:
   ```toml
   [tool.ruff]
   extend-config = ["https://raw.githubusercontent.com/graylayer-labs/.github/main/ruff.toml"]
   ```
5. **Adds `.claude/CLAUDE.md`** that imports org rules
6. **Commits & pushes** branch
7. **Creates a PR** with:
   - Title: `chore: sync org standards`
   - Labels: `type:chore`, `auto-merge`
   - Body: explains changes + auto-merge behavior
8. **Adds language-detected labels** (e.g., `source:PyTorch`)

### Usage

```bash
cd graylayer-labs/.github
./scripts/create-org-sync-prs.sh
```

This creates PRs for:
- `lang-goal-rl`
- `ssl-aerial-person-detection`
- `rl-evo-lab`
- `model-monitor-custom`
- `rl-core`

Each PR will:
- Run the code quality workflow
- Label-check (workflow won't enforce labels on PRs created by script, just warn)
- Auto-merge when all checks pass (enabled by `auto-merge` label)
- Auto-delete the feature branch

## Label Schema

All PRs and repos use standardized labels. See `.codex/label-schema.yaml` for full schema.

### Required Labels (per repo, not just PRs)

| Category | Example | Purpose |
|----------|---------|---------|
| `data:*` | `data:COCO/Detection` | What dataset/data source |
| `model:*` | `model:YOLO/v8` | What algorithm/model |
| `status:*` | `status:Experimental` | Maturity level |
| `source:*` | `source:PyTorch` | Framework/language |

### Optional Labels

| Category | Example |
|----------|---------|
| `type:*` | `type:bug`, `type:enhancement`, `type:documentation` |

## Implementation Checklist

### Before Running PR Script

- [ ] `.github` repo created with:
  - [ ] `.github/workflows/code-quality.yml` (auto-merge enabled)
  - [ ] `ruff.toml` (org-wide config)
  - [ ] `.codex/label-schema.yaml` (label definitions)
  - [ ] `.claude/` rules (quality-gate, labeling, python)
  - [ ] `scripts/create-org-sync-prs.sh` (PR creation)

- [ ] Labels synced to all repos via `scripts/label-sync.sh`

- [ ] Each repo has required labels:
  - [ ] At least one `data:*`
  - [ ] At least one `model:*`
  - [ ] At least one `status:*`
  - [ ] At least one `source:*`

### Running the System

1. **Create sync PRs:**
   ```bash
   cd graylayer-labs/.github
   ./scripts/create-org-sync-prs.sh
   ```

2. **Monitor PRs:**
   - Go to https://github.com/graylayer-labs/pulls
   - Each PR has labels `type:chore` and `auto-merge`
   - CI workflow runs automatically

3. **PRs auto-merge when:**
   - Language checks pass (ruff, ty for Python; eslint for JS; golangci-lint for Go)
   - Test suites pass (if configured)
   - Label validation passes (but script-created PRs may need manual review)
   - All other workflows pass (if any)
   - PR has `auto-merge` label

4. **Clean up:**
   - Script auto-deletes branches after merge
   - No manual cleanup needed

## Troubleshooting

### PR stuck (not auto-merging)

**Possible causes:**
1. **Missing `auto-merge` label** — workflow only auto-merges if label is present
2. **Ruff violation** — fix locally, push to update PR
3. **Type check error** — `ty` errors block the job, fix type issues
4. **Test failure** — fix tests and push
5. **Label validation failed** — missing required label on PR itself

**Fix:**
1. Check workflow run details: https://github.com/$ORG/$REPO/actions
2. Fix issues locally
3. Push to feature branch (PR auto-updates)
4. Workflow re-runs, auto-merges when all pass

### Ruff conflicts across repos

Each repo can override org config in `pyproject.toml`:

```toml
[tool.ruff]
extend-config = ["https://raw.githubusercontent.com/graylayer-labs/.github/main/ruff.toml"]
line-length = 88  # override if needed
```

Keep overrides minimal. If many overrides are needed, discuss in graylayer-labs/.github issues.

### Language not detected

The workflow checks for:
- Python: `pyproject.toml`
- JavaScript: `package.json`
- Go: `go.mod`

If your repo uses a different setup (e.g., `setup.py` instead of `pyproject.toml`), either:
1. Rename/create `pyproject.toml` (recommended)
2. Update workflow to detect your setup

## Future Enhancements

- [ ] Rust support (check for `Cargo.toml`)
- [ ] C/C++ support (check for `CMakeLists.txt`)
- [ ] YAML linting for GitHub Actions workflows
- [ ] Markdown linting (prettier)
- [ ] Dependency scanning (GitHub security)
- [ ] Code coverage reporting

## Related Documents

- [`.claude/rules/quality-gate.md`](.claude/rules/quality-gate.md) — Quality gate setup for individual repos
- [`.claude/rules/labeling.md`](.claude/rules/labeling.md) — Label schema and conventions
- [`.codex/label-schema.yaml`](.codex/label-schema.yaml) — Complete label catalog
- [`docs/new-repo-setup.md`](docs/new-repo-setup.md) — Template for new projects
