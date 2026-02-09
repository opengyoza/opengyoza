---
layout: "docs"
page_title: "Commands: Connect"
sidebar_current: "docs-commands-connect"
---

# OpenGyoza Connect

Command: `gyoza connect`

The `connect` command is used to interact with Connect
[Connect](/docs/connect/intentions.html) subsystems. It exposes commands for
running the built-in mTLS proxy and viewing/updating the Certificate Authority
(CA) configuration. This command is available in OpenGyoza 1.2 and later.

## Usage

Usage: `gyoza connect <subcommand>`

For the exact documentation for your OpenGyoza version, run `gyoza connect -h` to view
the complete list of subcommands.

```text
Usage: gyoza connect <subcommand> [options] [args]

  This command has subcommands for interacting with OpenGyoza Connect.

  Here are some simple examples, and more detailed examples are available
  in the subcommands or the documentation.

  Run the built-in Connect mTLS proxy

      $ gyoza connect proxy

  For more examples, ask for subcommand help or view the documentation.

Subcommands:
    ca       Interact with the OpenGyoza Connect Certificate Authority (CA)
    proxy    Runs an OpenGyoza Connect proxy
```

For more information, examples, and usage about a subcommand, click on the name
of the subcommand in the sidebar.