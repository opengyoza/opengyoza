---
layout: "docs"
page_title: "Commands: Snapshot"
sidebar_current: "docs-commands-snapshot"
---

# OpenGyoza Snapshot

Command: `gyoza snapshot`

The `snapshot` command has subcommands for saving, restoring, and inspecting the
state of the OpenGyoza servers for disaster recovery. These are atomic, point-in-time
snapshots which include key/value entries, service catalog, prepared queries,
sessions, and ACLs. This command is available in OpenGyoza 0.7.1 and later.

Snapshots are also accessible via the [HTTP API](/api/snapshot.html).

## Usage

Usage: `gyoza snapshot <subcommand>`

For the exact documentation for your OpenGyoza version, run `gyoza snapshot -h` to
view the complete list of subcommands.

```text
Usage: gyoza snapshot <subcommand> [options] [args]

  # ...

Subcommands:

    inspect    Displays information about an OpenGyoza snapshot file
    restore    Restores snapshot of OpenGyoza server state
    save       Saves snapshot of OpenGyoza server state
```

For more information, examples, and usage about a subcommand, click on the name
of the subcommand in the sidebar or one of the links below:

- [inspect](/docs/commands/snapshot/inspect.html)
- [restore](/docs/commands/snapshot/restore.html)
- [save](/docs/commands/snapshot/save.html)

## Basic Examples

To create a snapshot and save it as a file called "backup.snap":

```text
$ gyoza snapshot save backup.snap
Saved and verified snapshot to index 8419
```

To restore a snapshot from a file called "backup.snap":

```text
$ gyoza snapshot restore backup.snap
Restored snapshot
```

To inspect a snapshot from the file "backup.snap":

```text
$ gyoza snapshot inspect backup.snap
ID           2-5-1477944140022
Size         667
Index        5
Term         2
Version      1
```

For more examples, ask for subcommand help or view the subcommand documentation
by clicking on one of the links in the sidebar.
