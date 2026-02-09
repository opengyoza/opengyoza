# Compatibility Notes

## Goals
- Preserve compatibility with legacy Consul environments where feasible.
- Keep legacy environment variables, configuration keys, and API headers.

## Compatibility Guarantees
- **Environment variables:** `CONSUL_*` variables remain supported (e.g., `CONSUL_HTTP_ADDR`, `CONSUL_HTTP_TOKEN`).
- **Configuration keys:** Existing config file keys and CLI flags remain valid; OpenGyoza does not require renaming.
- **API headers:** Legacy HTTP headers (for example `X-Consul-*`) are preserved for clients and proxies.
- **Directory names:** Any remaining `consul/` directory names are kept strictly for compatibility with existing tooling and file paths (not endorsement).

## CLI Compatibility
- Primary CLI: `gyoza`.
- Compatibility shim: `consul` wrapper that forwards to `gyoza` with an opt-out warning.

## Documentation Compatibility
- Document `consul` -> `gyoza` migration steps.
- If `consul/` directory names remain, document that they are for compatibility, not endorsement.
