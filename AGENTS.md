# Repository Guidelines

## Project Structure & Module Organization
- Go module root: `go.mod` defines the main module. CLI entrypoints live in `cmd/gyoza` (primary) and `cmd/consul` (compatibility shim).
- Core runtime and libraries live under `agent/`, `connect/`, `lib/`, `tlsutil/`, and related packages.
- Client libraries are in `api/` (Go API) and `sdk/`.
- Web UI source lives in `ui-v2/`; published docs live in `website/source/docs/`.
- Build and release tooling lives in `build-support/` and `scripts/`; tests and fixtures live in `test/` and `testrpc/`.

## Build, Test, and Development Commands
- `make dev` builds local binaries into `./bin` and `$GOPATH/bin`.
- `make bin` builds release-style binaries for the current platform.
- `make test` runs the Go test suite with logging and vet checks; it fails if other `consul agent` processes are running.
- `make test-race` runs the suite with the race detector.
- `make ui` builds static UI assets (Docker-based); for UI work use `make -C ui-v2 start` and `make -C ui-v2 test`.
- `go test ./...` is acceptable for quick local checks.

## Coding Style & Naming Conventions
- Go code must be `gofmt`-formatted; run `make format` and `make vet` before submitting changes.
- Keep package names lower-case; exported identifiers follow Go naming conventions.
- CLI examples should use `gyoza`; keep `.consul` DNS domains and `CONSUL_*` env vars for compatibility.

## Testing Guidelines
- Prefer `make test` for full coverage; use `GOTEST_FLAGS` for timeouts or parallelism when needed.
- For long runs, capture output (e.g., `go test ./... > /tmp/test.log` then `wc -l /tmp/test.log`) before opening large logs.
- UI tests: `make -C ui-v2 test` and `make -C ui-v2 lint` when touching frontend code.

## Commit & Pull Request Guidelines
- The repo history is minimal; use short, imperative commit subjects and include a brief scope when helpful (e.g., `docs:`, `agent:`).
- Before committing, review `git status` and keep commits scoped; avoid `--amend` unless explicitly requested.
- PRs should include a concise summary, rationale, and test results; include screenshots for UI or docs layout changes.

## Agent Workflow
- Be proactive: continue with the next logical steps unless a hard decision or missing requirement blocks progress.
