# Compatibility Notes

## Goals
- Preserve compatibility with legacy Consul environments where feasible.
- Keep legacy environment variables, configuration keys, and API headers.

## CLI Compatibility
- Primary CLI: `gyoza`.
- Compatibility shim: `consul` wrapper that forwards to `gyoza` with an opt-out warning.

## Documentation Compatibility
- Document `consul` -> `gyoza` migration steps.
- If `consul/` directory names remain, document that they are for compatibility.
