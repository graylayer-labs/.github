# graylayer-labs Organization Configuration

Org-level Claude Code configuration for graylayer-labs.

## Imports

@rules/quality-gate.md
@rules/labeling.md
@rules/python.md

## Quick Reference

- **Quality Gate**: All Python PRs must pass ruff + ty (see [quality-gate.md](rules/quality-gate.md))
- **Language**: Python (uv + ruff + ty)
- **Labeling**: Mandatory labels on all repos (see [labeling.md](rules/labeling.md))
- **Repos must declare**: data:*, model:*, status:*, source:* labels
- **Tests**: Pytest, TDD-first on src/

## Repos in this Org

- **rl-core** — Shared RL infrastructure library
- **rl-evo-lab** — Evolutionary RL research project
- **graylayer.io** — Team website (Astro)

Each project should follow labeling conventions to make datasets, models, and status discoverable.
