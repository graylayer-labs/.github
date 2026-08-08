# Labeling Rules

All projects in graylayer-labs use standardized labels for discoverability and organization.

## Label Categories

See [.codex/label-schema.yaml](../../.codex/label-schema.yaml) for the full catalog.

### data:* — Datasets

Tag issues/PRs with the datasets they use:
- `data:COCO/Detection` — COCO object detection
- `data:Custom/Proprietary` — proprietary datasets
- `data:Synthetic` — synthetic data

### model:* — Models & Algorithms

Tag with the approach:
- `model:YOLO/v8` — YOLOv8
- `model:ViT` — Vision Transformer
- `model:SSL/SimCLR` — Self-supervised learning
- `model:Custom` — custom architecture

### status:* — Project Maturity

Always tag issues/PRs with status:
- `status:Experimental` — early stage, unvalidated
- `status:In-Progress` — active development
- `status:Stable` — validated, reproducible
- `status:Archived` — no longer active

### source:* — Framework/Language

- `source:PyTorch`
- `source:TensorFlow`
- `source:JAX`

### type:* — Issue/PR Type

- `type:bug`
- `type:enhancement`
- `type:documentation`
- `type:experiment`

## Usage

A typical PR for ssl-aerial-person-detection might have:
- `model:SSL/SimCLR`
- `data:Custom/Proprietary`
- `source:PyTorch`
- `status:Experimental`
- `type:enhancement`

This lets viewers quickly understand what's in the project.
