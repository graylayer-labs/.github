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

Python repositories in this org use:
- **Ruff** — linting and formatting
- **Pyright** — type checking
- **UV** — package management
- **Pytest** — testing

Before opening a PR:

```bash
uv sync                  # ensure dependencies are installed
ruff check --fix         # lint and auto-fix
ruff format              # format code
pyright                  # type check
pytest tests/            # run tests
```

Pre-commit hooks will catch formatting issues; fix them and re-push.

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
