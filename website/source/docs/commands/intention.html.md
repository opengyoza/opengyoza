---
layout: "docs"
page_title: "Commands: Intention"
sidebar_current: "docs-commands-intention"
---

# OpenGyoza Intention

Command: `gyoza intention`

The `intention` command is used to interact with Connect
[intentions](/docs/connect/intentions.html). It exposes commands for
creating, updating, reading, deleting, checking, and managing intentions.
This command is available in OpenGyoza 1.2 and later.

Intentions may also be managed via the [HTTP API](/api/connect/intentions.html).

## Usage

Usage: `gyoza intention <subcommand>`

For the exact documentation for your OpenGyoza version, run `gyoza intention -h` to view
the complete list of subcommands.

```text
Usage: gyoza intention <subcommand> [options] [args]

  ...

Subcommands:
    check     Check whether a connection between two services is allowed.
    create    Create intentions for service connections.
    delete    Delete an intention.
    get       Show information about an intention.
    match     Show intentions that match a source or destination.
```

For more information, examples, and usage about a subcommand, click on the name
of the subcommand in the sidebar.

## Basic Examples

Create an intention to allow "web" to talk to "db":

    $ gyoza intention create web db

Test whether a "web" is allowed to connect to "db":

    $ gyoza intention check web db

Find all intentions for communicating to the "db" service:

    $ gyoza intention match db

