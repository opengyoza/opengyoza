# Consul Diff Report

Base: HashiCorp Consul v1.6.4 (commit a13102a08250d7f5564f4f18e22182da23feb488).

## Summary
OpenGyoza is a compatibility-focused fork of Consul 1.6.4. The fork removes
enterprise/BSL-only code paths, renames the CLI to `gyoza` while keeping a
`consul` compatibility shim, and updates build/packaging/CI for dual binaries.
Docs and user-facing text are rebranded to OpenGyoza with explicit compatibility
notes for `CONSUL_*` environment variables and the `.consul` DNS domain.

Tests are green for full `go test ./...` as of 2026-02-02 (see Testing status).

## Diffstat
- Tracked changes (working tree vs base): 1803 files changed, 65479 insertions(+),
  195871 deletions(-).
- Untracked additions: 603 files (includes new root docs, scripts, CLI entrypoints,
  and a refreshed `vendor/` tree).

## Import-path rewrites vs functional changes
**Import-path & module updates**
- Module path switched to `github.com/opengyoza/opengyoza` with corresponding
  import rewrites across the codebase and submodules (`api/`, `sdk/`).
- Replace directives updated to point to local `api/` and `sdk/` modules.

**Functional changes**
- Enterprise/BSL-only functionality removed or stubbed (operator area/segment/license
  endpoints, enterprise delegate/client/server stubs, non-voting servers, network
  segment flags/fields, and related docs).
- CLI rename to `gyoza` with a `consul` shim for compatibility.
- Build, Docker, and CI updated to produce both binaries and to run on Go 1.24.
- Docs and public-facing text rebranded to OpenGyoza with compatibility callouts.

## Branding changes
- README, migration guide, and documentation rebranded to OpenGyoza.
- CLI examples switched to `gyoza`; `.consul` DNS and `CONSUL_*` env vars retained
  for compatibility.
- Links repointed to OpenGyoza GitHub org/docs where applicable; upstream tool
  guides retain original tool names with compatibility notes.

## Generated files notes
- `vendor/` refreshed (from `go mod vendor`), contributing a large portion of
  untracked additions.
- Generated artifacts (e.g., protobuf outputs, bindata assets) may have been
  updated where build scripts ran; verify before release if regeneration is required.

## Testing status
- Full `go test ./...` passed on 2026-02-02.
- `go test ./agent` may require a longer timeout; the full suite remains green.
