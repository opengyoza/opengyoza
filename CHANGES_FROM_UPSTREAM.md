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
