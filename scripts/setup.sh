#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
if [ "$#" -gt 1 ] || { [ "$#" -eq 1 ] && [ "$1" != "--cli-only" ]; }; then
  echo 'Usage: scripts/setup.sh [--cli-only]' >&2
  exit 2
fi
root=$(pwd)
mkdir -p .factory/bin
source_dir=$(mktemp -d)
trap 'rm -rf "$source_dir"' EXIT
./scripts/checkout-engine.sh "$source_dir"
go -C "$source_dir" build -o "$root/.factory/bin/factory" ./cmd/factory
if [ "${1:-}" = "--cli-only" ]; then
  exit 0
fi
CGO_ENABLED=0 GOOS=linux GOARCH="${FACTORY_CONTAINER_ARCH:-$(go env GOARCH)}" go -C "$source_dir" build -o "$root/.factory/bin/api-linux" ./cmd/api
docker buildx build --target workspace-assets --output "type=local,dest=$root/.factory/ui" "$source_dir"
