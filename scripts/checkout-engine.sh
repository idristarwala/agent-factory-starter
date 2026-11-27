#!/bin/sh
# Materialize the exact engine revision in a caller-provided empty directory.
set -eu
cd "$(dirname "$0")/.."
destination=${1:?supply an empty engine checkout directory}
pin=$(cat engine.commit)
case "$pin" in ''|*[!0-9a-f]*) echo 'Invalid engine.commit' >&2; exit 1;; esac
[ "${#pin}" -eq 40 ] || { echo 'Expected a full commit SHA' >&2; exit 1; }
mkdir -p "$destination"
[ -z "$(ls -A "$destination")" ] || { echo 'Engine checkout directory must be empty' >&2; exit 1; }
git -C "$destination" init -q
git -C "$destination" fetch -q --depth=1 https://github.com/idristarwala/agent-factory.git "$pin"
git -C "$destination" checkout -q --detach FETCH_HEAD
[ "$(git -C "$destination" rev-parse HEAD)" = "$pin" ]
