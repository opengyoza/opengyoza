---
layout: "docs"
page_title: "Commands: Validate"
sidebar_current: "docs-commands-validate"
description: >
  The `gyoza validate` command tests that config files are valid by
  attempting to parse them. Useful to ensure a configuration change will
  not cause the gyoza agent to fail after a restart.
---

# OpenGyoza Validate

The `gyoza validate` command performs a thorough sanity test on OpenGyoza
configuration files. For each file or directory given, the command will
attempt to parse the contents just as the `gyoza agent` command would,
and catch any errors.

This is useful to do a test of the configuration only, without actually
starting the agent. This performs all of the validation the agent would, so
this should be given the complete set of configuration files that are going
to be loaded by the agent. This command cannot operate on partial
configuration fragments since those won't pass the full agent validation.

For more information on the format of OpenGyoza's configuration files, read the
gyoza agent [Configuration Files](/docs/agent/options.html#configuration-files)
section.

## Usage

Usage: `gyoza validate [options] FILE_OR_DIRECTORY...`

Returns 0 if the configuration is valid, or 1 if there are problems.

```text
$ gyoza validate /etc/consul.d
Configuration is valid!
```
