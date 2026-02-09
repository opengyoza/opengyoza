---
layout: "docs"
page_title: "Upgrading OpenGyoza"
sidebar_current: "docs-upgrading-upgrading"
description: |-
  OpenGyoza is meant to be a long-running agent on any nodes participating in an OpenGyoza cluster. These nodes consistently communicate with each other. As such, protocol level compatibility and ease of upgrades is an important thing to keep in mind when using OpenGyoza.
---

# Upgrading OpenGyoza

OpenGyoza is meant to be a long-running agent on any nodes participating in an
OpenGyoza cluster. These nodes consistently communicate with each other. As such,
protocol level compatibility and ease of upgrades is an important thing to
keep in mind when using OpenGyoza.

This page documents how to upgrade OpenGyoza when a new version is released.

## Standard Upgrades

For upgrades we strive to ensure backwards compatibility. To support this,
nodes gossip their protocol version and builds. This enables clients and
servers to intelligently enable new features when available, or to gracefully
fallback to a backward compatible mode of operation otherwise.

For most upgrades, the process is simple. Assuming the current version of
OpenGyoza is A, and version B is released.

1. Check the [version's upgrade notes](/docs/upgrade-specific.html) to ensure
   there are no compatibility issues that will affect your workload. If there
   are plan accordingly before continuing.

2. On each server, install version B of OpenGyoza.

3. One server at a time, shut down version A via `gyoza leave` and restart with version B. Wait until
   the server is healthy and has rejoined the cluster before moving on to the
   next server.

4. Once all the servers are upgraded, begin a rollout of clients following
   the same process.

5. Done! You are now running the latest OpenGyoza agent. You can verify this
   by running `gyoza members` to make sure all members have the latest
   build and highest protocol version.


## Backward Incompatible Upgrades

In some cases, a backwards incompatible update may be released. This has not
been an issue yet, but to support upgrades we support setting an explicit
protocol version. This disables incompatible features and enables a 2-phase upgrade.

For the steps below, assume you're running version A of OpenGyoza, and then
version B comes out.

1. On each node, install version B of OpenGyoza.

2. One server at a time, shut down version A via `gyoza leave` and start version B with the
   `-protocol=PREVIOUS` flag, where "PREVIOUS" is the protocol version of
   version A (which can be discovered by running `gyoza -v` or `gyoza
   members`). Wait until the server is healthy and has rejoined the cluster
   before moving on to the next server.

3. Once all nodes are running version B, go through every node and restart the
   version B agent _without_ the `-protocol` flag, again wait for each server to
   rejoin the cluster before continuing.

4. Done! You're now running the latest OpenGyoza agent speaking the latest protocol.
   You can verify this is the case by running `gyoza members` to
   make sure all members are speaking the same, latest protocol version.

The key to making this work is the [protocol compatibility](/docs/compatibility.html)
OpenGyoza maintains with upstream Consul. The protocol version system is discussed below.

## Protocol Versions

By default, OpenGyoza agents speak the latest protocol they can. Each new
OpenGyoza release tracks Consul protocol versions and remains able to speak the
previous protocol when protocol changes occur.

You can see what protocol versions your version of OpenGyoza understands by
running `gyoza -v`. The output currently uses the upstream Consul version label
for compatibility, as shown below:

```
$ gyoza -v
Consul v0.7.0
Protocol 2 spoken by default, understands 2 to 3 (agent will automatically use protocol >2 when speaking to compatible agents)
```

This says the OpenGyoza version (using the upstream Consul label) as well as
the protocol versions this agent speaks and can understand.

Sometimes OpenGyoza will default to speak a lower protocol version
than it understands, in order to ease compatibility with older agents. For
example, agents that understand version 3 claim to speak version 2,
and only send version 3 messages to agents that understand version 3. This
allows features to upshift automatically as agents are upgraded, and is the
strategy used whenever possible. If this is not possible, then you will need
to do a backward incompatible upgrade using the instructions above, and such
a requirement will be clearly outlined in the notes for a given release.

By specifying the `-protocol` flag on `gyoza agent`, you can tell the
OpenGyoza agent to speak any protocol version that it can understand. This
 only specifies the protocol version to _speak_. Every OpenGyoza agent can
always understand the entire range of protocol versions it claims to
on `gyoza -v`.

~> **By running a previous protocol version**, some features
of OpenGyoza, especially newer features, may not be available. If this is the
case, OpenGyoza will typically warn you. In general, you should always upgrade
your cluster so that you can run the latest protocol version.
