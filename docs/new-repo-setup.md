# Setting Up a New Python Repo in graylayer-labs

Follow this checklist when creating a new Python project in the graylayer-labs org.

## 1. Initialize Project

```bash
gh repo create graylayer-labs/<project-name> --public --clone
cd <project-name>
git init
uv init --python 3.11
```

## 2. Create Project Structure

```
<project>/
├── src/
│   └── <project>/
│       └── __init__.py
├── tests/
│   └── test_*.py
├── pyproject.toml
├── .github/
│   └── workflows/
│       └── quality-gate.yml
└── .claude/
    └── CLAUDE.md
```

## 3. Configure `pyproject.toml`

```toml
[project]
name = "<project>"
version = "0.1.0"
description = ""
requires-python = ">=3.11"
dependencies = []

[tool.uv]
dev-dependencies = [
    "pytest",
    "ruff",
    "ty",
]

[tool.ruff]
extend-config = ["https://raw.githubusercontent.com/graylayer-labs/.github/main/ruff.toml"]
target-version = "py311"

[tool.pytest.ini_options]
testpaths = ["tests"]
```

## 4. Add Quality Gate Workflow

Create `.github/workflows/quality-gate.yml`:

```yaml
name: Quality Gate

on: [pull_request]

jobs:
  quality:
    uses: graylayer-labs/.github/.github/workflows/quality-gate.yml@main
```

## 5. Create `.claude/CLAUDE.md`

```markdown
# <Project> Configuration

Brief description of the project.

## Imports

@.github/.claude/CLAUDE.md
```

This inherits org-level configuration and rules.

## 6. Set Up GitHub Labels

```bash
# From graylayer-labs/.github:
./scripts/label-sync.sh graylayer-labs <project-name>
```

## 7. Create README

Include:
- **Goal/problem statement**
- **Dataset used** (link to data:* label)
- **Model/algorithm** (link to model:* label)
- **Framework** (PyTorch/TensorFlow/JAX)
- **Status** (Experimental/In-Progress/Stable)
- **How to run** — quick start commands
- **Results** (if applicable)

Example:
```markdown
# ssl-aerial-person-detection

Self-supervised person detection in aerial imagery.

- **Dataset**: Custom proprietary aerial imagery (~50k images)
- **Model**: SimCLR pre-training + YOLOv8 detection head
- **Framework**: PyTorch
- **Status**: Experimental
- **Paper**: [link if published]

## Quick Start
\`\`\`bash
uv sync
uv run python src/ssl_aerial/train.py
\`\`\`

## Results
- mAP@0.5: 0.72 (baseline)
- Inference: 45ms per image (RTX 3090)
```

## 8. First Commit

```bash
uv sync
uv run ruff check . && uv run ruff format .
uv run ty .
git add -A
git commit -m "chore: init project skeleton with quality gate"
git push -u origin main
```

## 9. Label Issues/PRs

When opening PRs or issues, apply labels from org schema:
- Exactly one `data:*`
- Exactly one `model:*`
- Exactly one `status:*`
- At least one `source:*`
- One or more `type:*` (for issues/PRs)

Example PR: "Add SimCLR pre-training"
```
Labels:
  - model:SSL/SimCLR
  - data:Custom/Proprietary
  - source:PyTorch
  - status:Experimental
  - type:enhancement
```

## Done

Your repo is now aligned with org standards. The quality gate will run automatically on all PRs.

---

**Questions?**
- See `.github/CONTRIBUTING.md` for labeling conventions
- See `.github/.claude/rules/` for tooling standards
- See `.github/ruff.toml` for linting rules
