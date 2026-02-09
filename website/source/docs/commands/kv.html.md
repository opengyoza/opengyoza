---
layout: "docs"
page_title: "Commands: KV"
sidebar_current: "docs-commands-kv"
---

# OpenGyoza KV

Command: `gyoza kv`

The `kv` command is used to interact with OpenGyoza's KV store via the
command line. It exposes top-level commands for inserting, updating, reading,
and deleting from the store. This command is available in OpenGyoza 0.7.1 and
later.

The KV store is also accessible via the
[HTTP API](/api/kv.html).

## Usage

Usage: `gyoza kv <subcommand>`

For the exact documentation for your OpenGyoza version, run `gyoza kv -h` to view
the complete list of subcommands.

```text
Usage: gyoza kv <subcommand> [options] [args]

  # ...

Subcommands:

    delete    Removes data from the KV store
    export    Exports part of the KV tree in JSON format
    get       Retrieves or lists data from the KV store
    import    Imports part of the KV tree in JSON format
    put       Sets or updates data in the KV store
```

For more information, examples, and usage about a subcommand, click on the name
of the subcommand in the sidebar or one of the links below:

- [delete](/docs/commands/kv/delete.html)
- [export](/docs/commands/kv/export.html)
- [get](/docs/commands/kv/get.html)
- [import](/docs/commands/kv/import.html)
- [put](/docs/commands/kv/put.html)

## Basic Examples

To create or update the key named "redis/config/connections" to the value "5" in
OpenGyoza's KV store:

```text
$ gyoza kv put redis/config/connections 5
Success! Data written to: redis/config/connections
```

To read a value back from OpenGyoza:

```text
$ gyoza kv get redis/config/connections
5
```

Or you can query for detailed information:

```text
$ gyoza kv get -detailed redis/config/connections
CreateIndex      336
Flags            0
Key              redis/config/connections
LockIndex        0
ModifyIndex      336
Session          -
Value            5
```

Finally, deleting a key is just as easy:

```text
$ gyoza kv delete redis/config/connections
Success! Data deleted at key: redis/config/connections
```

For more examples, ask for subcommand help or view the subcommand documentation
by clicking on one of the links in the sidebar.
