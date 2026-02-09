# OpenGyoza

OpenGyoza is a community-maintained, open-source fork of Consul 1.6.4 focused
on preserving compatibility while removing enterprise-only code. It provides
service discovery, health checking, a KV store, multi-datacenter support, and
service segmentation via Connect.

* GitHub: https://github.com/opengyoza/opengyoza
* Docs source: `website/` (published site TBD)

## CLI Naming

The primary CLI is `gyoza`. A `consul` compatibility shim is shipped alongside
the main binary to ease migration and existing automation.

## Migration from Consul

See the migration guide at `website/source/docs/guides/gyoza-migration.html.md`
for command mappings and compatibility notes.

## Security

Please report security issues via the process in `SECURITY.md`.

## Quick Start

Quick start documentation lives in `website/source/docs/install/` and will be
published once the OpenGyoza site is finalized.

## Documentation

Documentation lives in `website/source/docs/` and mirrors the upstream Consul
structure, with OpenGyoza-specific notes added where behavior differs.

## Contributing

Thank you for your interest in contributing! Please refer to `CONTRIBUTING.md`
for guidance.

## Trademark Notice

Consul is a trademark of HashiCorp. OpenGyoza is not affiliated with or
endorsed by HashiCorp.
