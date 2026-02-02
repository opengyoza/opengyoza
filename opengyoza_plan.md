# OpenGyoza Forking Plan (Consul v1.6.4)

This plan is based on the OpenWonton (Nomad v1.6.5) fork work and is intended as
handoff guidance for another LLM/collaborator.

## What “canonical Go module path” means

In Go, the module path is the identity of the module and the import prefix for
all packages. It is the first line in `go.mod`, for example:

```
module github.com/opengyoza/opengyoza
```

Changing the canonical module path means:
- Updating `go.mod` (and any nested module `go.mod`, e.g. `api/go.mod`).
- Rewriting import paths across the codebase.
- Downstream users must update imports to the new path.

For OpenGyoza, the canonical module path is:
- `github.com/opengyoza/opengyoza` (API: `github.com/opengyoza/opengyoza/api`).

## Decisions (already set)

- Upstream base: Consul v1.6.4 (record exact commit SHA + release date).
- Canonical module path: `github.com/opengyoza/opengyoza`.
- CLI: `gyoza` primary + `consul` compatibility shim.
- GitHub org + release URLs: `github.com/opengyoza/opengyoza`.
- Enterprise/BSL: remove entirely (as in OpenWonton).
- Compatibility: same approach as OpenWonton (legacy env vars/config/API).
- Tests: must be green before we say “working.”
- If any tests depend on Nomad, use OpenWonton: https://github.com/openwonton/openwonton

## Phase 0: Base selection + provenance

1) Pin upstream base
- Checkout Consul v1.6.4 tag.
- Record:
  - upstream repo URL
  - tag
  - commit SHA
  - release date
  - fork date

2) Create provenance/legal files (modeled on OpenWonton)
- `CHANGES_FROM_UPSTREAM.md`
- `LEGAL.md`
- `COMPATIBILITY.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `CLEAN_ROOM_NOTES.md`
- `CONSUL_DIFF_REPORT.md` (analog to `NOMAD_DIFF_REPORT.md`)

## Phase 1: Legal + license hygiene

1) Audit licensing
- `rg -n "BUSL-1.1|BSL" -S .`
- Identify enterprise/BSL areas.

2) Remove enterprise/BSL code + docs
- Remove any enterprise-only code and docs.
- Document all removals in `CHANGES_FROM_UPSTREAM.md`.

3) Clean-room replacements (if required)
- If removals break essential functionality/tests, write clean-room specs in
  `CLEAN_ROOM_NOTES.md` and implement minimal MPL replacements.

4) MPL header audit
- Add `scripts/audit-mpl-headers.sh` modeled after OpenWonton.
- Run it and fix missing headers or document exceptions in `LEGAL.md`.

## Phase 2: Go module path + imports

1) Set module path
- Root `go.mod`: `module github.com/opengyoza/opengyoza`
- Any submodule (likely `api/go.mod`): `github.com/opengyoza/opengyoza/api`

2) Rewrite import paths
- Replace `github.com/hashicorp/consul` with `github.com/opengyoza/opengyoza`.
- Update other internal paths as needed.

3) Replace directive
- Add `replace github.com/opengyoza/opengyoza/api => ./api` in root `go.mod`.

## Phase 3: CLI rename + shim

1) Primary CLI
- Create `cmd/gyoza/main.go` from upstream Consul main.
- Update CLI name, help text, and usage to `gyoza`.

2) Compatibility shim
- Create `cmd/consul/main.go` shim modeled on OpenWonton’s `cmd/nomad/main.go`.
- Behavior:
  - Resolve `gyoza` binary in same directory or PATH.
  - Print a warning by default.
  - Allow suppression via env var (e.g. `GYOZA_CONSUL_SHIM_SILENT=1`).

3) Build + packaging
- `GNUmakefile`: build both `gyoza` and `consul`.
- Packaging should include both binaries.

4) Docker
- `Dockerfile`: copy both binaries, entrypoint runs `gyoza`.
- `scripts/docker-entrypoint.sh`: update banner text and env var names.

## Phase 4: Branding + docs

1) README
- Rename to OpenGyoza.
- Add intent statement.
- Add trademark disclaimer for Consul.
- Document CLI rename + shim.

2) Docs + website
- Update CLI examples to `gyoza`.
- Add migration guide: `consul` -> `gyoza`.
- Update links to GitHub org: `github.com/opengyoza/opengyoza`.

3) Legal docs
- Add `website/content/legal.mdx` (or equivalent) with MPL + trademark notes.

4) Remove enterprise/BSL docs
- Remove enterprise/BSL documentation sections.

## Phase 5: CI + release

1) GH Actions
- Update workflows to produce OpenGyoza artifacts.
- Ensure both `gyoza` and `consul` are built and uploaded.

2) Release metadata
- Update versioning and release titles to OpenGyoza.

3) Packaging
- Ensure checksums and archive names use `gyoza`.

## Phase 6: Compatibility guarantees

Match OpenWonton:
- Keep legacy env vars (e.g., `CONSUL_*`).
- Keep config keys and API headers.
- If directory names like `consul/` remain, document that this is for
  compatibility (not endorsement).

## Phase 7: Tests are the North Star (TDD-style)

- All tests must be green before declaring the fork “working.”
- Run tests locally as part of every change (TDD workflow):
  - Add or update tests first (red).
  - Implement changes to make tests pass (green).
  - Refactor while keeping tests green.
- If tests depend on Nomad, use OpenWonton instead of upstream Nomad:
  https://github.com/openwonton/openwonton
  - CI Nomad integration jobs should clone OpenWonton (main + v0.8.7).
- When running tests, redirect output to a file and check line count with
  `wc -l` before opening (per repo rules).

## Phase 8: Diff report

- Create `CONSUL_DIFF_REPORT.md` mirroring `NOMAD_DIFF_REPORT.md`:
  - base commit
  - diffstat
  - import-path rewrites vs functional changes
  - branding changes
  - generated files notes

---

### Execution Checklist

- [x] Pin upstream v1.6.4 tag + SHA; record in `LEGAL.md` and
      `CHANGES_FROM_UPSTREAM.md`.
- [x] Remove enterprise/BSL code + docs; document removals.
      - Sentinel hooks removed; operator area/segment/license API stubs removed;
        enterprise delegate/client/server stubs removed; autopilot enterprise
        fields removed. Non-voting server and network segment config/flags/CLI
        outputs removed; docs updated accordingly. Residual "enterprise" mentions
        are limited to comments/compatibility notes.
- [x] Set module path to `github.com/opengyoza/opengyoza` and update imports.
- [x] Implement `gyoza` CLI + `consul` shim.
      - Root `main.go` moved to `cmd/gyoza`; `cmd/consul` shim resolves `gyoza` and warns by default.
- [x] Update build/packaging/Docker/CI for new binaries.
      - Build scripts now produce `gyoza` + `consul`, release packaging includes both; dev Docker copies both and entrypoint runs `gyoza`. Added root `Dockerfile` + `scripts/docker-entrypoint.sh` to run `gyoza`. CI updated for Go 1.24 and dual binaries.
- [x] Rebrand CI and release metadata defaults.
      - CircleCI cache keys and author metadata updated; release-site messaging and docker build tags aligned to OpenGyoza.
- [x] Switch download references to GitHub releases.
      - Website downloads, demo Vagrantfile, and benchmark templates now pull from GitHub release assets; publish tooling uses GitHub CLI.
- [x] Update README, docs, website branding, legal + migration guide.
      - README updated; migration guide added; docs index/guides index and site layout links updated.
      - CLI examples updated to `gyoza` across commands/guides/install/platform docs. Branding sweep complete; legal page added under docs; remaining: any non-docs legal updates if required.
      - Branding sweep in progress: core docs/guides headers updated to OpenGyoza; install/upgrading/k8s index + run + service sync pages rebranded (anchors updated); k8s helm/connect/out-of-cluster/ambassador/dns pages rebranded with upstream chart notes; kubernetes production deploy + kuberenetes deployment + minikube guides updated; kubernetes observability guide rebranded with upstream chart notes; production ACL guide annotated for upstream compatibility; monitoring-telegraf, windows, FAQ, upgrade-specific, and install subpages updated; upstream-tool guides now carry compatibility notes; consul.io doc links repointed to local docs/api.
      - Latest guide updates: servers, dns-cache, forwarding, datacenters, connect-production, connect-gateways, outage (Consul base notes), agent-encryption (log output + base note), creating-certificates, acl, autopilot (base note + typo fix), consul-template, consul-aws, consul-containers, containers-guide (log output), production-acls (base note), acl-index, kubernetes-reference, kubernetes-production-deploy, kubernetes-observability (terminology cleanup). (acl-legacy now has a compatibility note; connect-envoy partially). Consul containers guide clarified upstream container wording.
      - Remaining "Consul" mentions in guides are now limited to upstream tool names, compatibility notes (env vars/DNS/API headers), or historical version references.
- [x] Run MPL header audit and license scans.
      - MPL header audit script added and run (2026-01-29).
      - BSL keyword scan run on 2026-02-02; matches limited to planning/legal notes and vendor syscall names.
- [x] Ensure tests are green.
      - Full `go test ./...` passes (2026-02-02).
- [x] Produce `CONSUL_DIFF_REPORT.md`.
