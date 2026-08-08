# Labeling Rules & Standards

All graylayer-labs repositories use standardized labels to make projects discoverable and track development status transparently.

## Label Categories

See [.codex/label-schema.yaml](.codex/label-schema.yaml) for the complete catalog.

### Required Labels (per repo)

Every repo MUST have labels applied to classify its primary purpose:

**Exactly one `data:*` label** (what dataset does this work with?)
- `data:COCO/Detection` — COCO object detection
- `data:COCO/Segmentation` — COCO segmentation
- `data:Custom/Proprietary` — proprietary/custom dataset
- `data:Synthetic` — synthetic data
- `data:Benchmark` — benchmark-only (no specific dataset)

**Exactly one `model:*` label** (what algorithm/architecture?)
- `model:YOLO/v8`, `model:ResNet`, `model:ViT`
- `model:SSL/SimCLR`, `model:SSL/MoCo`
- `model:Custom` — custom architecture
- `model:Ensemble` — multiple models

**Exactly one `status:*` label** (maturity level?)
- `status:Experimental` — early stage, not validated
- `status:In-Progress` — active development
- `status:Stable` — validated, reproducible, documented
- `status:Archived` — no longer active

**At least one `source:*` label** (framework/language?)
- `source:PyTorch`
- `source:TensorFlow`
- `source:JAX`

### Issue/PR Labels

When opening issues or PRs:
- `type:bug` — bug fix
- `type:enhancement` — new feature or improvement
- `type:documentation` — docs/guides
- `type:experiment` — experimental work (not for main)

## How to Label a Repo

Once labels are synced to your repo (via org script), apply to issues/PRs:

Example: ssl-aerial-person-detection
```
Issue: "Add aerial person detection baseline"
Labels:
  - model:SSL/SimCLR
  - data:Custom/Proprietary
  - source:PyTorch
  - status:Experimental
  - type:enhancement
```

Viewers immediately see: self-supervised + custom aerial data + PyTorch, still experimental.

## Syncing Labels to New/Existing Repos

If a repo is missing labels, run:
```bash
cd graylayer-labs/.github
./scripts/label-sync.sh graylayer-labs <repo-name>
```

Or sync all org repos:
```bash
./scripts/label-sync.sh graylayer-labs
```

## Enforcement

- **Org-level:** Labels defined in `.codex/label-schema.yaml`
- **Enforcement:** Manual (GitHub Actions label validation coming soon)
- **CI:** Quality gate checks code, not labels — label consistently by convention

## Adding New Labels

If your repo needs a label not in the schema:
1. Open an issue in `graylayer-labs/.github`
2. Discuss whether it belongs in org-wide schema
3. Add to `.codex/label-schema.yaml` + sync to all repos

Keep labels sparse — use README for detailed documentation.
