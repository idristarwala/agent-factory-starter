#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
root=$(pwd)
pin=$(cat engine.commit)
case "$pin" in ''|*[!0-9a-f]*) echo 'Invalid engine.commit' >&2; exit 1;; esac
[ "${#pin}" -eq 40 ] || { echo 'Expected a full commit SHA' >&2; exit 1; }
mkdir -p .factory/bin
source_dir=$(mktemp -d)
trap 'rm -rf "$source_dir"' EXIT
git -C "$source_dir" init -q
git -C "$source_dir" fetch -q --depth=1 https://github.com/idristarwala/agent-factory.git "$pin"
git -C "$source_dir" checkout -q --detach FETCH_HEAD
[ "$(git -C "$source_dir" rev-parse HEAD)" = "$pin" ]
go -C "$source_dir" build -o "$root/.factory/bin/factory" ./cmd/factory
CGO_ENABLED=0 GOOS=linux GOARCH="${FACTORY_CONTAINER_ARCH:-$(go env GOARCH)}" go -C "$source_dir" build -o "$root/.factory/bin/api-linux" ./cmd/api
