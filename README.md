# Agent Factory starter

A versioned workspace for defining your own record types, editable fields and review rules. The example assigns a category from a source record. The engine is pinned to the full Git revision in `engine.commit`.

## Run locally

From the repository root, use Git, Go 1.26+, a POSIX shell and Docker Compose v2.

```sh
./scripts/setup.sh
.factory/bin/factory validate
.factory/bin/factory test
.factory/bin/factory up
curl --fail http://127.0.0.1:8080/health
```

The setup script fetches and verifies the pinned upstream revision and builds the management CLI for your host and the API for Linux. Set `FACTORY_CONTAINER_ARCH` before setup if the Docker engine uses a different architecture (for example, `arm64`). Set `FACTORY_PORT` before startup to change the loopback port. Run `docker compose down` to stop the API. Its SQLite workspace persists in a named volume.

The fixture supplies scripted worker and judge responses. The API can start without a provider key. For live model calls, edit the endpoint and model IDs in `gateway.yaml` for your model server and restart the API. The supplied route expects an OpenAI-compatible local server reachable from Docker on port 11434. For authenticated routes, mount the credential file separately. The small local container supports this text example. For production deployments or PDF extraction use the engine image built by this repository. [Gateway configuration](https://github.com/idristarwala/agent-factory/blob/main/docs/ENTERPRISE_GATEWAY.md) · [Production deployment](https://github.com/idristarwala/agent-factory/blob/main/docs/DEPLOYMENT.md)

## Build and publish images

Engine development happens in [agent-factory](https://github.com/idristarwala/agent-factory). This repository owns image builds and releases. To adopt a source change, update `engine.commit` to the full reviewed engine commit and open a starter pull request. CI fetches that revision into a temporary directory, builds the engine, worker, connector and binaries, and verifies the images by digest in a disposable registry. The starter keeps the pin, configuration and workflows in Git.

A `v*` tag in this repository publishes the three images to `ghcr.io/idristarwala/agent-factory-starter` and attaches the binaries, license and `release-manifest.json` to the starter GitHub Release. Deploy from the manifest's `images.engine`, `images.worker` or `images.connector` reference. Its `source.commit` identifies the engine revision and `build.commit` identifies the starter revision that built it.

## Define a factory

Edit `packs/review/definition.json` for your record type and editable fields. Edit `packs/review/pack.yaml` for worker roles and rules. Add cases under `fixtures/` with independently specified expected changes and verdicts. Register additional pack directories in `factory.yaml`. To generate CI evidence for a committed pack, run:

```sh
.factory/bin/factory test --receipt packs/review/pack.yaml > test-evidence.json
```

## License

Copyright © 2026 Idris Tarwala. Copying, modifying or distributing this software requires prior written permission from the copyright holder. [License](LICENSE)
