# Contributing to graylayer-labs

## Labeling Conventions

All repositories in graylayer-labs follow a standardized labeling scheme to make projects discoverable and transparent about what data, models, and frameworks they use.

### When to Label

- **PRs**: Label with data, model, source, and status tags
- **Issues**: Label with type (bug/enhancement/documentation) and status
- **Discussions**: Label if discussing a specific project or dataset

### Label Format

Labels follow the pattern `category:value`:

```
data:COCO/Detection        # datasets
model:YOLO/v8              # algorithms and architectures
status:Stable              # project maturity
source:PyTorch             # framework
type:enhancement           # issue/PR type
```

See [.codex/label-schema.yaml](.codex/label-schema.yaml) for the full catalog.

### Example

For a PR adding self-supervised person detection on custom aerial imagery:

```
Labels:
- model:SSL/SimCLR
- data:Custom/Proprietary
- source:PyTorch
- status:Experimental
- type:enhancement
```

Viewers can immediately see what the project contains.

## Code Quality

All Python repositories in this org must pass the **Quality Gate** before merging.

**Tools:**
- **Ruff** — linting and formatting (org-wide config in `ruff.toml`)
- **ty** — type checking (warnings don't block, errors should be fixed)
- **UV** — package management
- **Pytest** — testing

**Before opening a PR:**

```bash
uv sync                     # ensure dependencies are installed
uv run ruff check --fix     # lint and auto-fix
uv run ruff format          # format code
uv run ty .                 # type check
uv run pytest tests/        # run tests
```

**The Quality Gate runs on every PR:**
- Ruff violations **block** the PR
- Type check warnings **don't block** (but should be fixed)
- Test failures **block** the PR

See [.claude/rules/quality-gate.md](.claude/rules/quality-gate.md) for setup details.

## Commit Messages

Use Conventional Commits:
```
feat(model): add SimCLR self-supervised learning
fix(data): correct COCO annotation loading
docs: update README with dataset schema
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`

One logical change per commit.

## Questions?

See `.claude/CLAUDE.md` for org-level configuration and Claude Code rules.
