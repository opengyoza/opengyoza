---
layout: "docs"
page_title: "Commands"
sidebar_current: "docs-commands"
description: |-
  OpenGyoza is controlled via a simple command-line interface (CLI). The primary CLI is `gyoza` and it takes subcommands such as agent or members. The complete list of subcommands is in the navigation to the left.
---

# OpenGyoza Commands (CLI)

OpenGyoza is controlled via a very easy to use command-line interface (CLI).
The primary CLI is `gyoza`. This application then takes a subcommand such as
"agent" or "members". The complete list of subcommands is in the navigation to
the left.

The `gyoza` CLI is a well-behaved command line application. In erroneous
cases, a non-zero exit status will be returned. It also responds to `-h` and `--help`
as you'd most likely expect. And some commands that expect input accept
"-" as a parameter to tell OpenGyoza to read the input from stdin.

OpenGyoza ships a `consul` compatibility shim to ease migration. Existing
automation that invokes `consul` will continue to work, but you should prefer
`gyoza` in new scripts.

To view a list of the available commands at any time, just run `gyoza` with
no arguments:

```text
$ gyoza
Usage: gyoza [--version] [--help] <command> [<args>]

Available commands are:
    acl            Interact with OpenGyoza's ACLs
    agent          Runs an OpenGyoza agent
    catalog        Interact with the catalog
    connect        Interact with OpenGyoza Connect
    debug          Records a debugging archive for operators
    event          Fire a new event
    exec           Executes a command on OpenGyoza nodes
    force-leave    Forces a member of the cluster to enter the "left" state
    info           Provides debugging information for operators.
    intention      Interact with Connect service intentions
    join           Tell OpenGyoza agent to join cluster
    keygen         Generates a new encryption key
    keyring        Manages gossip layer encryption keys
    kv             Interact with the key-value store
    leave          Gracefully leaves the OpenGyoza cluster and shuts down
    lock           Execute a command holding a lock
    login          Login to OpenGyoza using an auth method
    logout         Destroy an OpenGyoza token created with login
    maint          Controls node or service maintenance mode
    members        Lists the members of an OpenGyoza cluster
    monitor        Stream logs from an OpenGyoza agent
    operator       Provides cluster-level tools for OpenGyoza operators
    reload         Triggers the agent to reload configuration files
    rtt            Estimates network round trip time between nodes
    services       Interact with services
    snapshot       Saves, restores and inspects snapshots of OpenGyoza server state
    tls            Builtin helpers for creating CAs and certificates
    validate       Validate config files/directories
    version        Prints the OpenGyoza version
    watch          Watch for changes in OpenGyoza
```

To get help for any specific command, pass the `-h` flag to the relevant
subcommand. For example, to see help about the `join` subcommand:

```text
$ gyoza join -h
Usage: gyoza join [options] address ...

  Tells a running OpenGyoza agent (with "gyoza agent") to join the cluster
  by specifying at least one existing member.

HTTP API Options

  -http-addr=<address>
     The `address` and port of the OpenGyoza HTTP agent. The value can be
     an IP address or DNS address, but it must also include the port.
     This can also be specified via the CONSUL_HTTP_ADDR environment
     variable. The default value is http://127.0.0.1:8500. The scheme
     can also be set to HTTPS by setting the environment variable
     CONSUL_HTTP_SSL=true.

  -token=<value>
     ACL token to use in the request. This can also be specified via the
     CONSUL_HTTP_TOKEN environment variable. If unspecified, the query
     will default to the token of the OpenGyoza agent at the HTTP address.

Command Options

  -wan
     Joins a server to another server in the WAN pool.
```

## Autocompletion

The `gyoza` command features opt-in subcommand autocompletion that you can
enable for your shell with `gyoza -autocomplete-install`. After doing so,
you can invoke a new shell and use the feature.

For example, assume a tab is typed at the end of each prompt line:

```
$ gyoza e
event  exec

$ gyoza r
reload  rtt

$ gyoza operator raft
list-peers   remove-peer
```

## Environment Variables

In addition to CLI flags, OpenGyoza reads environment variables for behavior
defaults. CLI flags always take precedence over environment variables, but it
is often helpful to use environment variables to configure the OpenGyoza agent,
particularly with configuration management and init systems.

These environment variables and their purpose are described below:

## `CONSUL_HTTP_ADDR`

This is the HTTP API address to the *local* OpenGyoza agent
(not the remote server) specified as a URI with optional scheme:

```
CONSUL_HTTP_ADDR=127.0.0.1:8500
```

or as a Unix socket path:

```
CONSUL_HTTP_ADDR=unix://var/run/consul_http.sock
```

If the `https://` scheme is used, `CONSUL_HTTP_SSL` is implied to be true.

### `CONSUL_HTTP_TOKEN`

This is the API access token required when access control lists (ACLs)
are enabled, for example:

```
CONSUL_HTTP_TOKEN=aba7cbe5-879b-999a-07cc-2efd9ac0ffe
```

### `CONSUL_HTTP_TOKEN_FILE`

This is a path to a file containing the API access token required when access
control lists (ACLs) are enabled, for example:

```
CONSUL_HTTP_TOKEN_FILE=/path/to/gyoza.token
```

### `CONSUL_HTTP_AUTH`

This specifies HTTP Basic access credentials as a username:password pair:

```
CONSUL_HTTP_AUTH=operations:JPIMCmhDHzTukgO6
```

### `CONSUL_HTTP_SSL`

This is a boolean value (default is false) that enables the HTTPS URI
scheme and SSL connections to the HTTP API:

```
CONSUL_HTTP_SSL=true
```

### `CONSUL_HTTP_SSL_VERIFY`

This is a boolean value (default true) to specify SSL certificate verification;
setting this value to `false` is not recommended for production use. Example for
development purposes:

```
CONSUL_HTTP_SSL_VERIFY=false
```

### `CONSUL_CACERT`

Path to a CA file to use for TLS when communicating with OpenGyoza.

```
CONSUL_CACERT=ca.crt
```

### `CONSUL_CAPATH`

Path to a directory of CA certificates to use for TLS when communicating with OpenGyoza.

```
CONSUL_CAPATH=ca_certs/
```

### `CONSUL_CLIENT_CERT`

Path to a client cert file to use for TLS when `verify_incoming` is enabled.

```
CONSUL_CLIENT_CERT=client.crt
```

### `CONSUL_CLIENT_KEY`

Path to a client key file to use for TLS when `verify_incoming` is enabled.

```
CONSUL_CLIENT_KEY=client.key
```

### `CONSUL_TLS_SERVER_NAME`

The server name to use as the SNI host when connecting via TLS.

```
CONSUL_TLS_SERVER_NAME=consulserver.domain
```

### `CONSUL_GRPC_ADDR`

Like [`CONSUL_HTTP_ADDR`](#consul_http_addr) but configures the address the
local agent is listening for gRPC requests. Currently gRPC is only used for
integrating [Envoy proxy](/docs/connect/proxies/envoy.html) and must be [enabled
explicitly](/docs/agent/options.html#grpc_port) in agent configuration.

```
CONSUL_GRPC_ADDR=127.0.0.1:8502
```

or as a Unix socket path:

```
CONSUL_GRPC_ADDR=unix://var/run/consul_grpc.sock
```

If the agent is [configured with TLS
certificates](/docs/agent/encryption.html#rpc-encryption-with-tls), then the
gRPC listener will require TLS and present the same certificate as the https
listener. As with `CONSUL_HTTP_ADDR`, if TLS is enabled either the `https://`
scheme should be used, or `CONSUL_HTTP_SSL` set.
