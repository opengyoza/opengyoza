# Changes From Upstream

Base: HashiCorp Consul v1.6.4 (tag), commit a13102a08250d7f5564f4f18e22182da23feb488.

## Status
- Forking work in progress. Enterprise/BSL code and documentation are being removed,
  with CLI/API/config changes underway.

## Planned Change Categories
- Module path and import rewrites to `github.com/opengyoza/opengyoza`.
- CLI rename to `gyoza` with a `consul` compatibility shim.
- Removal of Enterprise/BSL code and documentation.
- Branding and documentation updates.

## Change Log
- 2026-01-29: Initialized change log with upstream baseline.
- 2026-01-29: Removed Enterprise-specific documentation pages and website
  navigation/marketing links; cleaned up references to removed pages.
- 2026-01-29: Removed additional Enterprise-only docs and links (Sentinel,
  network areas/segments, snapshot agent), updated guides and API docs to avoid
  removed endpoints, and added `scripts/audit-mpl-headers.sh`.
- 2026-01-29: Removed Enterprise-only API client stubs (operator area/segment/
  license) and excised Sentinel integration from ACL policy parsing and
  enforcement.
- 2026-01-29: Removed Enterprise-only Autopilot fields (redundancy zone and
  upgrade migration) from config/CLI/tests/docs and API docs.
- 2026-01-29: Removed non-voting server and network segment config/flags/CLI
  outputs; updated agent member APIs and docs/examples to drop segment filtering.
- 2026-02-02: Ran BSL keyword scan; documented results in `LEGAL.md`.
- 2026-02-02: Added Go toolchain directive (Go 1.24.0) across root, api, and sdk modules.
- 2026-02-02: Added governance docs (`AGENTS.md`, `CONTRIBUTING.md`,
  `COMPATIBILITY.md`, `SECURITY.md`, `CLEAN_ROOM_NOTES.md`,
  `CHANGES_FROM_UPSTREAM.md`, `CONSUL_DIFF_REPORT.md`) and updated security
  reporting guidance.
- 2026-02-02: Refreshed docs/README references to OpenGyoza (API client,
  SDK testutil, UI README, community/security/downloads pages, and select
  docs links). Updated upgrade-specific guidance to remove enterprise-only
  sections and align CLI examples with `gyoza`.
- 2026-02-02: Tests green for full `go test ./...`.
- 2026-02-02: Updated CI and release metadata defaults for OpenGyoza (CircleCI
  cache keys, CI author metadata, release-site messaging, and docker build tags).
- 2026-02-02: Switched download/release URLs to GitHub releases for OpenGyoza
  (website downloads, demo Vagrantfile, and benchmark templates) and updated
  publish tooling to use the GitHub CLI.
- 2026-02-02: Nomad integration jobs now clone OpenWonton (`openwonton/openwonton`)
  for compatibility testing.
- 2026-02-02: Added GitHub Actions workflows for tests, build artifacts, and
  release uploads to GitHub releases.
