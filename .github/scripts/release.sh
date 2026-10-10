#!/usr/bin/env bash
# Create a tag and GitHub release when the commit message asks for one:
#   [release patch] | [release minor] | [release major] | [release v1.4.0]
# Commits without the marker do nothing. DRY_RUN=1 prints instead of creating.
set -euo pipefail

sha=$(git rev-parse "${GITHUB_SHA:-HEAD}")
msg=$(git log -1 --format=%B "$sha")

marker=$(grep -oE '\[release (major|minor|patch|v[0-9]+\.[0-9]+\.[0-9]+)\]' <<<"$msg" | head -1 || true)
if [ -z "$marker" ]; then
  echo "No [release ...] marker in the commit message. Nothing to do."
  exit 0
fi

arg=${marker#\[release }
arg=${arg%\]}

latest=$(git tag --list | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1 || true)
latest=${latest:-v0.0.0}
IFS=. read -r major minor patch <<<"${latest#v}"

case "$arg" in
  major) next="v$((major + 1)).0.0" ;;
  minor) next="v${major}.$((minor + 1)).0" ;;
  patch) next="v${major}.${minor}.$((patch + 1))" ;;
  v*)    next="$arg" ;;
esac

# Reuse the version tag on retries of a relative release marker.
case "$arg" in
  major|minor|patch)
    tagged=$(git tag --points-at "$sha" | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1 || true)
    next=${tagged:-$next}
    ;;
esac

echo "Release $next (previous: $latest)"
if [ "${DRY_RUN:-0}" = 1 ]; then
  exit 0
fi

if gh release view "$next" >/dev/null 2>&1; then
  echo "Release $next already exists. Nothing to do."
  exit 0
fi

gh release create "$next" --target "$sha" --title "$next" --generate-notes
