---
layout: "docs"
page_title: "Commands: Services"
sidebar_current: "docs-commands-services"
---

# OpenGyoza Agent Services

Command: `gyoza services`

The `services` command has subcommands for interacting with OpenGyoza services
registered with the [local agent](/docs/agent/basics.html). These provide
useful commands such as `register` and `deregister` for easily registering
services in scripts, dev mode, etc.
To view all services in the catalog, instead of only agent-local services,
see the [`catalog services`](/docs/commands/catalog/services.html) command.

## Usage

Usage: `gyoza services <subcommand>`

For the exact documentation for your OpenGyoza version, run `gyoza services -h` to
view the complete list of subcommands.

```text
Usage: gyoza services <subcommand> [options] [args]

  ...

Subcommands:
    deregister    Deregister services with the local agent
    register      Register services with the local agent
```

For more information, examples, and usage about a subcommand, click on the name
of the subcommand in the sidebar.

## Basic Examples

To create a simple service:

```text
$ gyoza services register -name=web
```

To create a service from a configuration file:

```text
$ cat web.json
{
  "Service": {
    "Name": "web"
  }
}

$ gyoza services register web.json
```

To deregister a service:

```sh
# Either style works:
$ gyoza services deregister web.json

$ gyoza services deregister -id web
```
