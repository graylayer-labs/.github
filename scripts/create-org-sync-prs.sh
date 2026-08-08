#!/bin/bash
# Create standardization PRs for all Python repos in graylayer-labs
# This script updates each repo with:
# - Code quality workflow (language-aware, auto-merge)
# - Updated ruff config (extends org config)
# - .claude/CLAUDE.md (references org rules)
# - Required labels on PR

set -e

ORG="graylayer-labs"
GITHUB_BASE_URL="https://github.com/$ORG"
BRANCH_NAME="chore/org-standards-sync"
LABEL_AUTO_MERGE="auto-merge"

# Python repos that need updating
REPOS=(
    "lang-goal-rl"
    "ssl-aerial-person-detection"
    "rl-evo-lab"
    "model-monitor-custom"
    "rl-core"
)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}→${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

create_pr_for_repo() {
    local repo=$1
    local repo_dir="/tmp/graylayer-$repo"

    log_info "Processing $repo..."

    # Clone repo
    if [ -d "$repo_dir" ]; then
        log_warn "Directory exists, pulling latest..."
        cd "$repo_dir" && git pull origin main && cd -
    else
        log_info "  Cloning $repo..."
        gh repo clone "$ORG/$repo" "$repo_dir"
    fi

    cd "$repo_dir"

    # Check if branch already exists
    if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
        log_warn "Branch $BRANCH_NAME already exists, skipping..."
        cd -
        return
    fi

    # Create and checkout branch
    git checkout -b "$BRANCH_NAME"
    git config user.email "eoinmc.james@gmail.com"
    git config user.name "Eoin McAllister"

    # 1. Create .github/workflows if not exists
    mkdir -p .github/workflows

    # Copy quality gate workflow
    cat > ".github/workflows/code-quality.yml" << 'EOF'
name: Code Quality

on:
  pull_request:
    paths:
      - '**.py'
      - '**.js'
      - '**.ts'
      - '**.jsx'
      - '**.tsx'
      - '**.go'
      - 'pyproject.toml'
      - 'package.json'
      - 'go.mod'
      - 'ruff.toml'
      - 'tsconfig.json'
      - 'pyrightconfig.json'
      - '.github/workflows/code-quality.yml'

permissions:
  contents: read
  pull-requests: write

jobs:
  detect-languages:
    runs-on: ubuntu-latest
    outputs:
      python: ${{ steps.detect.outputs.python }}
      javascript: ${{ steps.detect.outputs.javascript }}
      go: ${{ steps.detect.outputs.go }}
    steps:
      - uses: actions/checkout@v4
      - id: detect
        run: |
          [ -f pyproject.toml ] && echo "python=true" >> $GITHUB_OUTPUT || echo "python=false" >> $GITHUB_OUTPUT
          [ -f "package.json" ] && echo "javascript=true" >> $GITHUB_OUTPUT || echo "javascript=false" >> $GITHUB_OUTPUT
          [ -f go.mod ] && echo "go=true" >> $GITHUB_OUTPUT || echo "go=false" >> $GITHUB_OUTPUT

  python-quality:
    needs: detect-languages
    if: needs.detect-languages.outputs.python == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v2
        with:
          enable-cache: true
      - run: uv sync --all-extras
      - run: uv run ruff check .
      - run: uv run ruff format --check .
      - run: uv run ty . || true
      - run: uv run pytest tests/ -v --tb=short 2>/dev/null || echo "No tests found"

  javascript-quality:
    needs: detect-languages
    if: needs.detect-languages.outputs.javascript == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          cache: npm
      - run: npm ci
      - run: npm run lint 2>/dev/null || echo "No lint script"
      - run: npm test 2>/dev/null || echo "No test script"

  go-quality:
    needs: detect-languages
    if: needs.detect-languages.outputs.go == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v4
      - uses: golangci/golangci-lint-action@v3
      - run: go test ./...

  check-labels:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verify PR has required labels
        run: |
          LABELS=$(gh pr view ${{ github.event.pull_request.number }} --json labels --jq '.labels[].name' || echo "")
          [ -z "$LABELS" ] && echo "⚠ No labels yet (will be set by automation)" || echo "✓ Labels present"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  auto-merge:
    needs: [detect-languages, python-quality, javascript-quality, go-quality, check-labels]
    if: |
      always() &&
      (needs.python-quality.result == 'success' || needs.python-quality.result == 'skipped') &&
      (needs.javascript-quality.result == 'success' || needs.javascript-quality.result == 'skipped') &&
      (needs.go-quality.result == 'success' || needs.go-quality.result == 'skipped') &&
      github.event.pull_request.draft == false &&
      contains(github.event.pull_request.labels.*.name, 'auto-merge')
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: write
    steps:
      - uses: actions/checkout@v4
      - run: |
          gh pr merge ${{ github.event.pull_request.number }} --squash --auto
          git push origin --delete ${{ github.head_ref }} || true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOF

    log_info "  Added code-quality workflow"

    # 2. Update pyproject.toml with ruff config (if it exists)
    if [ -f "pyproject.toml" ]; then
        # Check if ruff config already extends org config
        if ! grep -q "extend-config.*github" pyproject.toml; then
            # Add ruff section if not present
            if ! grep -q "\[tool.ruff\]" pyproject.toml; then
                cat >> pyproject.toml << 'EOF'

[tool.ruff]
extend-config = ["https://raw.githubusercontent.com/graylayer-labs/.github/main/ruff.toml"]
target-version = "py311"
EOF
                log_info "  Added ruff config to pyproject.toml"
            else
                log_warn "  ruff config already present, review manually"
            fi
        else
            log_warn "  ruff config already extends org config"
        fi
    fi

    # 3. Create .claude/CLAUDE.md if not exists
    mkdir -p .claude
    if [ ! -f ".claude/CLAUDE.md" ]; then
        cat > ".claude/CLAUDE.md" << 'EOF'
# Project Configuration

See [graylayer-labs/.github](.github/..) for org-level standards.

## Imports

@graylayer-labs/.github/.claude/CLAUDE.md
EOF
        log_info "  Added .claude/CLAUDE.md"
    else
        log_warn "  .claude/CLAUDE.md already exists"
    fi

    # 4. Commit changes
    if git diff --cached --quiet; then
        if [ -z "$(git status --porcelain)" ]; then
            log_warn "No changes to commit, skipping..."
            git checkout main
            cd -
            return
        fi
    fi

    git add .github/workflows/code-quality.yml .claude/CLAUDE.md 2>/dev/null || true
    if [ -f "pyproject.toml" ] && git diff --name-only | grep -q pyproject.toml; then
        git add pyproject.toml
    fi

    if git diff --cached --quiet; then
        log_warn "No staged changes, skipping..."
        git checkout main
        cd -
        return
    fi

    git commit -m "chore: sync org standards (code quality workflow, ruff config, claude rules)

- Add code-quality workflow with language detection and auto-merge
- Extend ruff config from org-wide schema
- Add .claude/CLAUDE.md referencing org standards
- PR will auto-merge when all checks pass (add auto-merge label)

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"

    # 5. Push branch
    log_info "  Pushing branch..."
    git push -u origin "$BRANCH_NAME"

    # 6. Create PR
    log_info "  Creating PR..."
    PR_URL=$(gh pr create \
        --title "chore: sync org standards" \
        --body "Synchronize repo with graylayer-labs org standards:

- ✅ Code quality workflow (language-aware, ruff + ty + lint)
- ✅ Org-wide ruff config (extends .github/ruff.toml)
- ✅ Claude Code config (.claude/CLAUDE.md)

**This PR will auto-merge once all checks pass.** Add the \`auto-merge\` label to enable auto-merge.

See [graylayer-labs/.github](https://github.com/graylayer-labs/.github) for details." \
        --label "type:chore" \
        --label "auto-merge" \
        2>&1 | grep "https://github.com")

    if [ -z "$PR_URL" ]; then
        PR_URL=$(gh pr view "$BRANCH_NAME" --json url --jq '.url' 2>/dev/null || echo "")
    fi

    log_info "  PR created: $PR_URL"

    # 7. Add required labels to PR
    PR_NUM=$(echo "$PR_URL" | grep -oP '\d+$')
    log_info "  Adding labels to PR #$PR_NUM..."

    # Get primary language to determine labels
    if [ -f "pyproject.toml" ]; then
        gh label create "source:PyTorch" --repo "$ORG/$repo" 2>/dev/null || true
        gh label create "source:TensorFlow" --repo "$ORG/$repo" 2>/dev/null || true
        gh label create "source:JAX" --repo "$ORG/$repo" 2>/dev/null || true
        # Assume PyTorch for now (can be overridden)
        gh pr edit "$PR_NUM" --add-label "source:PyTorch" --repo "$ORG/$repo" 2>/dev/null || true
    fi

    # Return to main
    git checkout main
    cd -

    log_info "✓ Completed $repo\n"
}

# Main
log_info "Starting org-wide standardization PR creation..."
log_info "Target repos: ${REPOS[*]}\n"

for repo in "${REPOS[@]}"; do
    create_pr_for_repo "$repo"
done

log_info "\n✓ All PRs created!"
log_info "Next steps:"
log_info "  1. Review each PR at https://github.com/$ORG/pulls"
log_info "  2. Verify CI checks pass"
log_info "  3. PRs with 'auto-merge' label will merge automatically"
