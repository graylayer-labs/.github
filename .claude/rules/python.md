# Python Tooling Rules

This org uses **UV** for package management, **Ruff** for linting/formatting, and **ty** for type checking.

## Package Management — UV

**Always use UV**, never bare pip/pip3:
```bash
uv add <package>              # runtime dependency
uv add --dev <package>        # dev dependency
uv sync                       # sync env from lockfile
uv run <cmd>                  # run in project env
```

Commit lockfiles (`uv.lock`) alongside dependency changes in `chore` commits.

## Linting & Formatting — Ruff

Run before every commit:
```bash
ruff check --fix              # auto-fix issues
ruff format                   # format code
```

Config lives in `pyproject.toml` under `[tool.ruff]`.

**Pre-commit hook**: Runs ruff on staged files before commit. Let it fix automatically.

## Type Checking — ty

```bash
uv run ty .                   # type check entire project
uv run ty src/mymodule.py     # type check specific file
```

Type issues are warnings in CI; errors in `ty` output don't block PRs but should be fixed. Don't suppress with `# type: ignore` unless there's a specific reason documented.

## Quality Gate

All Python repos MUST pass the org quality gate before merging. See [quality-gate.md](quality-gate.md) for setup and requirements.

## Tests

Tests run with pytest. TDD-first on src/ — no edits to `src/` without a failing test.

```bash
pytest tests/
uv run pytest tests/
```
