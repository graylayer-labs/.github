# Setting Up a New Python Repo in graylayer-labs

Follow this checklist when creating a new Python project in the graylayer-labs org.

## 1. Create the Repo from the Template

New repos start from the `graylayer-labs/repo-template` template repo and are
**private by default**. Making a repo public is a separate, deliberate step
(see "Going public" below).

```bash
gh repo create graylayer-labs/<project-name> --private \
  --template graylayer-labs/repo-template --clone
cd <project-name>
```

The template provides:

```
<project>/
├── .github/
│   ├── workflows/ci.yml          # job `checks`
│   ├── ISSUE_TEMPLATE/task.md
│   ├── pull_request_template.md
│   └── dependabot.yml            # GitHub Actions, monthly, grouped
├── .gitignore
├── LICENSE                       # MIT
├── README.md
└── pyproject.toml
```

## 2. Fill In the Placeholders and Add the Package

Replace `<repo-name>`, `<package>`, `<one line>` and `<year>` in
`pyproject.toml`, `README.md` and `LICENSE`, then add the source and test
layout:

```
src/<package>/__init__.py
tests/test_<something>.py
```

## 3. Tooling (`pyproject.toml`)

The template already sets this up. For reference:

- **Python 3.12**: `requires-python = ">=3.12"`, ruff `target-version = "py312"`,
  `[tool.ty.environment] python-version = "3.12"`
- **uv** for environments and dependencies; `uv.lock` is committed
- **Dev tools** in `[dependency-groups] dev`: `pytest`, `ruff`, `ty`
- **Ruff**: `line-length = 88`, `select = ["E", "F", "I", "UP", "B", "SIM"]`

```bash
uv lock
uv sync --dev
```

## 4. CI

`.github/workflows/ci.yml` runs on pull requests and on pushes to `main`. Its
`checks` job runs:

```bash
uv sync --dev --locked
uv run ruff check .
uv run ruff format --check .
uv run ty check
uv run pytest
```

The job is skipped while a repo is still marked as a template, so it only runs
in repos created from it.

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

## 7. Write the README

Say what the repo is in one paragraph, its status
(Experimental/In progress/Stable), how to install and run it, and how to test
it. Add the dataset, model and framework where they apply.

## 8. First Commit, Settings and Board

The skeleton is the only commit that goes straight to `main`:

```bash
uv sync --dev
uv run ruff check . && uv run ruff format --check . && uv run ty check && uv run pytest
git add pyproject.toml uv.lock README.md LICENSE src tests
git commit -m "chore: add project skeleton"
git push origin main
```

Then set the repo up:

- **Merge settings**: squash merge only, delete branch on merge, wiki off.
- **Labels**: at least `bug`, `enhancement`, `chore`, `documentation`.
- **Metadata**: description and topics.
- **Board**: one Project per active research repo, linked to the repo.

Everything after the skeleton goes through a branch named
`<type>/<issue>-<slug>` (types `feat fix refactor test docs chore`), a draft PR
with `Closes #N`, and a squash merge. Every PR closes a task issue that is on
the board under an epic.

### Going public

Only after checking the full history (all branches) for secrets, account
identifiers, personal context, third-party material and committed junk. Once
public, turn on:

- Secret scanning, push protection, Dependabot alerts and security updates
- Branch protection on `main`: require the `checks` status check
- Auto-merge

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

Your repo is now aligned with org standards. CI runs the `checks` job on every PR.

---

**Questions?**
- See `.github/CONTRIBUTING.md` for labeling conventions
- See `.github/.claude/rules/` for tooling standards
- See `.github/ruff.toml` for linting rules
