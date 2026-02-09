---
layout: "docs"
page_title: "Commands: Config"
sidebar_current: "docs-commands-config"
---

# OpenGyoza Config

Command: `gyoza config`

The `config` command is used to interact with OpenGyoza's central configuration
system. It exposes commands for creating, updating, reading, and deleting
different kinds of config entries. See the
[agent configuration](/docs/agent/options.html#enable_central_service_config)
for more information on how to enable this functionality for centrally
configuring services and [configuration entries docs](/docs/agent/config_entries.html) for a description
of the configuration entries content.

## Usage

Usage: `gyoza config <subcommand>`

For the exact documentation for your OpenGyoza version, run `gyoza config -h` to view
the complete list of subcommands.

```text
Usage: gyoza config <subcommand> [options] [args]

  This command has subcommands for interacting with OpenGyoza's centralized
  configuration system. Here are some simple examples, and more detailed
  examples are available in the subcommands or the documentation.

  Write a config:

    $ gyoza config write web.serviceconf.hcl

  Read a config:

    $ gyoza config read -kind service-defaults -name web

  List all configs for a type:

    $ gyoza config list -kind service-defaults

  Delete a config:

    $ gyoza config delete -kind service-defaults -name web

  For more examples, ask for subcommand help or view the documentation.
```

For more information, examples, and usage about a subcommand, click on the name
of the subcommand in the sidebar.