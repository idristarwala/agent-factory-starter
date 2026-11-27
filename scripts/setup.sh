#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
root=$(pwd)
mkdir -p .factory/bin
source_dir=$(mktemp -d)
trap 'rm -rf "$source_dir"' EXIT
./scripts/checkout-engine.sh "$source_dir"
go -C "$source_dir" build -o "$root/.factory/bin/factory" ./cmd/factory
CGO_ENABLED=0 GOOS=linux GOARCH="${FACTORY_CONTAINER_ARCH:-$(go env GOARCH)}" go -C "$source_dir" build -o "$root/.factory/bin/api-linux" ./cmd/api
