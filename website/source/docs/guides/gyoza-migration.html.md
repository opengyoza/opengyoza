---
layout: "docs"
page_title: "Migrate from Consul to OpenGyoza"
sidebar_current: "docs-guides-gyoza-migration"
description: |-
  Migration steps and compatibility notes for moving from Consul to OpenGyoza.
---

# Migrate from Consul to OpenGyoza

OpenGyoza is a fork of Consul 1.6.4 with a focus on compatibility. Most users
can migrate with minimal changes.

## 1) Install OpenGyoza

Download the OpenGyoza release for your platform and place `gyoza` in your PATH.
A `consul` shim binary is shipped alongside it for compatibility.

## 2) Update CLI usage

Use `gyoza` as the primary CLI. Existing scripts that call `consul` will still
work, but will emit a warning unless you silence it.

Examples:

```
consul agent -dev
consul members
consul kv get config/app
```

becomes:

```
gyoza agent -dev
gyoza members
gyoza kv get config/app
```

To silence the shim warning, set:

```
GYOZA_CONSUL_SHIM_SILENT=1
```

## 3) Keep config, environment variables, and headers

Configuration files, API endpoints, legacy `CONSUL_*` environment variables, and
`X-Consul-*` HTTP headers are preserved for compatibility. You can keep existing
config and gradually update any tooling that hard-codes `consul` paths or flags.

## 4) Update Go imports (if applicable)

If you import the Go API client, update module paths:

```
# old
import "github.com/hashicorp/consul/api"

# new
import "github.com/opengyoza/opengyoza/api"
```

## 5) Verify behavior

Run a small canary cluster and confirm:

- Agents start and join as expected.
- Service registration and health checks behave the same.
- ACLs and Connect features operate without drift.

If you find a compatibility gap, please report it in `CHANGES_FROM_UPSTREAM.md`.
