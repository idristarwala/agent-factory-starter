#!/bin/sh
# Build in a clean engine checkout and return release assets to this workspace.
set -eu
cd "$(dirname "$0")/.."
root=$(pwd)
source_dir=$(mktemp -d)
trap 'rm -rf "$source_dir"' EXIT
./scripts/checkout-engine.sh "$source_dir"
starter_commit=$(git rev-parse HEAD)
engine_commit=$(cat engine.commit)
cd "$source_dir"
# The engine script emits KEY=sha256:digest lines for the three pushed images.
digests=$(mktemp -p "$source_dir")
GITHUB_ENV="$digests" sh scripts/push-release-images.sh
set -a
. "$digests"
set +a
make release
python3 scripts/release-manifest.py dist
jq --arg engine "$engine_commit" --arg starter "$starter_commit" --arg repo "$GITHUB_REPOSITORY" \
  '.source = {repository:"idristarwala/agent-factory",commit:$engine} | .build = {repository:$repo,commit:$starter}' \
  dist/release-manifest.json > manifest.json
mv manifest.json dist/release-manifest.json
mkdir -p "$root/.factory"
# A fresh directory prevents obsolete assets from entering a later release.
[ ! -e "$root/.factory/release" ] || { echo 'Release output directory already exists' >&2; exit 1; }
mv dist "$root/.factory/release"
