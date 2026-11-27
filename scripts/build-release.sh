#!/bin/sh
# Build in a clean engine checkout and return release assets to this workspace.
set -eu
cd "$(dirname "$0")/.."
root=$(pwd)
output=$root/.factory/release
[ ! -e "$output" ] || { echo 'Release output directory already exists' >&2; exit 1; }
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
source_dir=$work/engine
./scripts/checkout-engine.sh "$source_dir"
starter_commit=$(git rev-parse HEAD)
engine_commit=$(cat engine.commit)
cd "$source_dir"
make release
mv dist "$work/assets"
# The engine script emits KEY=sha256:digest lines for the three pushed images.
digests=$work/digests
GITHUB_ENV="$digests" sh scripts/push-release-images.sh
set -a
. "$digests"
set +a
python3 scripts/release-manifest.py "$work/assets"
jq --arg engine "$engine_commit" --arg starter "$starter_commit" --arg repo "$GITHUB_REPOSITORY" \
  '.source = {repository:"idristarwala/agent-factory",commit:$engine} | .build = {repository:$repo,commit:$starter}' \
  "$work/assets/release-manifest.json" > "$work/manifest.json"
mv "$work/manifest.json" "$work/assets/release-manifest.json"
mkdir -p "$root/.factory"
mv "$work/assets" "$output"
