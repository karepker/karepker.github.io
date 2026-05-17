#!/usr/bin/env bash
set -euo pipefail

# Builds the site and pushes the result to the gh-pages branch, which
# GitHub Pages serves at karepker.com.
#
# Invoke from the repo root: ./_util/deploy.sh

root_dir="$(cd "$(dirname "$0")/../"; pwd -P)"
cd "$root_dir"

source_sha=$(git rev-parse --short HEAD)

if [ -n "$(git status --porcelain)" ]; then
    echo "Refusing to deploy: uncommitted changes in working tree." >&2
    exit 1
fi

# Ensure _site/ is a worktree checked out to gh-pages. If anything is off
# (missing .git pointer, wrong branch), rebuild it from scratch. Otherwise
# git operations inside _site/ would silently fall through to the parent
# repo and commit to master.
site_branch=$(git -C _site symbolic-ref --quiet HEAD 2>/dev/null || true)
if [ "$site_branch" != "refs/heads/gh-pages" ]; then
    git worktree remove --force _site 2>/dev/null || true
    git worktree prune
    rm -rf _site
    git fetch origin gh-pages
    git worktree add -B gh-pages _site origin/gh-pages
fi

# Wipe the previous build. The worktree's .git pointer file is untracked
# and excluded by git clean, so it survives.
(
    cd _site
    git rm -rf . 2>/dev/null || true
    git clean -fdx
)

./_util/build.sh
touch _site/.nojekyll

(
    cd _site
    git add -A
    if git diff --cached --quiet; then
        echo "Nothing to deploy."
        exit 0
    fi
    git commit -m "Deploy ${source_sha}."
    git push origin gh-pages
)
