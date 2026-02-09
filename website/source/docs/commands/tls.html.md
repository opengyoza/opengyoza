---
layout: "docs"
page_title: "Commands: TLS"
sidebar_current: "docs-commands-tls"
---

# OpenGyoza TLS

Command: `gyoza tls`

The `tls` command is used to help with setting up a CA and certificates for OpenGyoza TLS.

## Basic Examples

Create a CA:

```text
$ gyoza tls ca create
==> Saved consul-agent-ca.pem
==> Saved consul-agent-ca-key.pem
```

Create a client certificate:

```text
$ gyoza tls cert create -client
==> Using consul-agent-ca.pem and consul-agent-ca-key.pem
==> Saved consul-client-dc1-0.pem
==> Saved consul-client-dc1-0-key.pem
```

For more examples, ask for subcommand help or view the subcommand documentation
by clicking on one of the links in the sidebar.

## Usage

Usage: `gyoza tls <subcommand> <subcommand> [options]`

For the exact documentation for your OpenGyoza version, run `gyoza tls -h` to
view the complete list of subcommands.

```text
Usage: gyoza tls <subcommand> <subcommand> [options]

  # ...

Subcommands:
  ca      Helpers for CAs
  cert    Helpers for certificates
```

For more information, examples, and usage about a subcommand, click on the name
of the subcommand in the sidebar or one of the links below:
