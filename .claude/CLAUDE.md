# graylayer-labs Organization Configuration

Org-level Claude Code configuration for graylayer-labs.

## Imports

@rules/python.md
@rules/labeling.md

## Quick Reference

- **Language**: Python (uv + ruff + pyright)
- **Labeling**: See [label schema](../.codex/label-schema.yaml)
- **Tests**: Pytest, TDD-first on src/
- **Pre-commit**: Ruff format/check, pyright type checking

## Repos in this Org

- **rl-core** — Shared RL infrastructure library
- **rl-evo-lab** — Evolutionary RL research project
- **graylayer.io** — Team website (Astro)

Each project should follow labeling conventions to make datasets, models, and status discoverable.
