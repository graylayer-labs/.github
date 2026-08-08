# Quality Gate Rule for Python Repos

All Python repositories in graylayer-labs MUST pass the org quality gate before merging to main.

## What the Quality Gate Checks

1. **Ruff Linting** — Code style, imports, common bugs
   - Uses org-wide config (`.github/ruff.toml`)
   - Runs `ruff check` and `ruff format --check`
2. **Type Checking** — Static type analysis with `ty`
   - Optional-only: warnings don't block, errors do
3. **Tests** — Pytest if present
   - Skips silently if no tests configured

## How to Set Up in Your Repo

### 1. Add to `.github/workflows/quality-gate.yml`

```yaml
name: Quality Gate

on: [pull_request]

jobs:
  quality:
    uses: graylayer-labs/.github/.github/workflows/quality-gate.yml@main
```

### 2. Configure `pyproject.toml`

```toml
[tool.ruff]
# Extend org defaults
extend-config = ["https://raw.githubusercontent.com/graylayer-labs/.github/main/ruff.toml"]
# Or copy locally and reference: extend-config = ["../../.github/ruff.toml"]

[build-system]
requires = ["setuptools", "wheel"]

[project]
python = ">=3.11"  # REQUIRED: specify version constraint
```

### 3. Ensure `ty` is configured

Create `pyrightconfig.json` or add to `pyproject.toml`:

```json
{
  "typeCheckingMode": "standard",
  "pythonVersion": "3.11"
}
```

Or in `pyproject.toml`:
```toml
[tool.pyright]
typeCheckingMode = "standard"
pythonVersion = "3.11"
```

## Before Pushing

Run locally:
```bash
uv sync
uv run ruff check . && uv run ruff format .
uv run ty .
uv run pytest tests/
```

## Violations

- **Ruff failures** block the PR (non-negotiable: formatting, imports, bugs)
- **Type check failures** are warnings (fix if possible, document if not)
- **Test failures** block the PR

## Repo-Specific Configuration

You can override the org defaults in your own `pyproject.toml`:

```toml
[tool.ruff]
extend-config = ["https://raw.githubusercontent.com/graylayer-labs/.github/main/ruff.toml"]
line-length = 88  # override if needed for your project
```

But keep it minimal — if you need many exceptions, file an issue in graylayer-labs/.github.
