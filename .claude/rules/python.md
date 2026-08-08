# Python Tooling Rules

This workspace uses **UV** for package management and **Ruff** + **Pyright** for quality.

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

## Type Checking — Pyright

```bash
pyright <file>
uv run pyright <file>
```

Fix type errors; don't suppress with `# type: ignore` unless there's a specific error code and reason.

## Tests

Tests run with pytest. TDD-first on src/ — no edits to `src/` without a failing test.

```bash
pytest tests/
uv run pytest tests/
```
