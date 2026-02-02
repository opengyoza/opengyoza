# OpenGyoza Internals Guide

This guide is intended to help folks who want to understand more about how OpenGyoza works from a code perspective, or who are thinking about contributing to OpenGyoza. For a high level overview of OpenGyoza's design, please see the [OpenGyoza Architecture Guide](/docs/internals/architecture.html) as a starting point.

## Architecture Overview

OpenGyoza is designed around the concept of an [OpenGyoza Agent](/docs/agent/basics.html). The agent is deployed as a single Go binary and runs on every node in a cluster.

A small subset of agents, usually 3 to 7, run in server mode and participate in the [Raft Consensus Protocol](/docs/internals/consensus.html). The OpenGyoza servers hold a consistent view of the state of the cluster, including the [service catalog](/api/catalog.html) and the [health state of services and nodes](/api/health.html) as well as other items like OpenGyoza's [key/value store contents](/api/kv.html). An agent in server mode is a superset of the client capabilities that follow.

All the remaining agents in a cluster run in client mode. Applications on client nodes use their local agent in client mode to [register services](/api/agent.html) and to discover other services or interact with the key/value store. For the latter queries, the agent sends RPC requests internally to one of the OpenGyoza servers for the information. None of the key/value data is on any of the client agents, for example, it's always fetched on the fly from an OpenGyoza server.

Both client and server mode agents participate in a [Gossip Protocol](/docs/internals/gossip.html) which provides two important mechanisms. First, it allows for agents to learn about all the other agents in the cluster, just by joining initially with a single existing member of the cluster. This allows clients to discover new OpenGyoza servers. Second, the gossip protocol provides a distributed failure detector, whereby the agents in the cluster randomly probe each other at regular intervals. Because of this failure detector, OpenGyoza can run health checks locally on each agent and just sent edge-triggered updates when the state of a health check changes, confident that if the agent dies altogether then the cluster will detect that. This makes OpenGyoza's health checking design very scaleable compared to centralized systems with a central polling type of design.

There are many other aspects of OpenGyoza that are well-covered in OpenGyoza's [Internals Guides](/docs/internals/index.html).

## Source Code Layout

### Shared Components

The components in this section are shared between OpenGyoza agents in client and server modes.

| Directory | Contents |
| --------- | -------- |
| [command/agent](https://github.com/opengyoza/opengyoza/tree/main/command/agent) | This contains the actual CLI command implementation for the `gyoza agent` command (and the `consul` shim), which mostly just invokes an agent object from the `agent` package. |
| [agent](https://github.com/opengyoza/opengyoza/tree/main/agent) | This is where the agent object is defined, and the top level `agent` package has all of the functionality that's common to both client and server agents. This includes things like service registration, the HTTP and DNS endpoints, watches, and top-level glue for health checks. |
| [agent/config](https://github.com/opengyoza/opengyoza/tree/main/agent/config) | This has all the user-facing [configuration](/docs/agent/options.html) processing code, as well as the internal configuration structure that's used by the agent. |
| [agent/checks](https://github.com/opengyoza/opengyoza/tree/main/agent/checks) | This has implementations for the different [health check types](/docs/agent/checks.html). |
| [agent/ae](https://github.com/opengyoza/opengyoza/tree/main/agent/ae), [agent/local](https://github.com/opengyoza/opengyoza/tree/main/agent/local) | These are used together to power the agent's [Anti-Entropy Sync Back](/docs/internals/anti-entropy.html) process to the OpenGyoza servers. |
| [agent/router](https://github.com/opengyoza/opengyoza/tree/main/agent/router), [agent/pool](https://github.com/opengyoza/opengyoza/tree/main/agent/pool) | These are used for routing RPC queries to OpenGyoza servers and for connection pooling. |
| [agent/structs](https://github.com/opengyoza/opengyoza/tree/main/agent/structs) | This has definitions of all the internal RPC protocol request and response structures. |

### Server Components

The components in this section are only used by OpenGyoza servers.

| Directory | Contents |
| --------- | -------- |
| [agent/consul](https://github.com/opengyoza/opengyoza/tree/main/agent/consul) | This is where the OpenGyoza server object is defined, and the top-level `consul` package has all of the functionality that's used by server agents. This includes things like the internal RPC endpoints. |
| [agent/consul/fsm](https://github.com/opengyoza/opengyoza/tree/main/agent/consul/fsm), [agent/consul/state](https://github.com/opengyoza/opengyoza/tree/main/agent/consul/state) | These components make up OpenGyoza's finite state machine (updated by the Raft consensus algorithm) and backed by the state store (based on immutable radix trees). All updates of OpenGyoza's consistent state is handled by the finite state machine, and all read queries to the OpenGyoza servers are serviced by the state store's data structures. |
| [agent/consul/autopilot](https://github.com/opengyoza/opengyoza/tree/main/agent/consul/autopilot) | This contains a package of functions that provide OpenGyoza's [Autopilot](/docs/guides/autopilot.html) features. |

### Other Components

There are several other top-level packages used internally by OpenGyoza as well as externally by other applications.

| Directory | Contents |
| --------- | -------- |
| [acl](https://github.com/opengyoza/opengyoza/tree/main/api) | This supports the underlying policy engine for OpenGyoza's [ACL](/docs/guides/acl.html) system. |
| [api](https://github.com/opengyoza/opengyoza/tree/main/api) | This `api` package provides an official Go API client for OpenGyoza, which is also used by OpenGyoza's [CLI](/docs/commands/index.html) commands to communicate with the local OpenGyoza agent. |
| [command](https://github.com/opengyoza/opengyoza/tree/main/command) | This contains a sub-package for each of OpenGyoza's [CLI](/docs/commands/index.html) command implementations. |
| [snapshot](https://github.com/opengyoza/opengyoza/tree/main/snapshot) | This has implementation details for OpenGyoza's [snapshot archives](/api/snapshot.html). |
| [watch](https://github.com/opengyoza/opengyoza/tree/main/watch) | This has implementation details for OpenGyoza's [watches](/docs/agent/watches.html), used both internally to OpenGyoza and by the [watch CLI command]](/docs/commands/watch.html). |
| [website](https://github.com/opengyoza/opengyoza/tree/main/website) | This has the full source code for the OpenGyoza documentation site. Pull requests can update the source code and OpenGyoza's documentation all together. |

## FAQ

This section addresses some frequently asked questions about OpenGyoza's architecture.

### How does eventually-consistent gossip relate to the Raft consensus protocol?

When you query OpenGyoza for information about a service, such as via the [DNS interface](/docs/agent/dns.html), the agent will always make an internal RPC request to an OpenGyoza server that will query the consistent state store. Even though an agent might learn that another agent is down via gossip, that won't be reflected in service discovery until the current Raft leader server perceives that through gossip and updates the catalog using Raft. You can see an example of where these layers are plumbed together here - https://github.com/opengyoza/opengyoza/blob/main/agent/consul/leader.go#L559-L602.

## Why does a blocking query sometimes return with identical results?

OpenGyoza's [blocking queries](/api/index.html#blocking-queries) make a best-effort attempt to wait for new information, but they may return the same results as the initial query under some circumstances. First, queries are limited to 10 minutes max, so if they time out they will return. Second, due to OpenGyoza's prefix-based internal immutable radix tree indexing, there may be modifications to higher-level nodes in the radix tree that cause spurious wakeups. In particular, waiting on things that do not exist is not very efficient, but not very expensive for OpenGyoza to serve, so we opted to keep the code complexity low and not try to optimize for that case. You can see the common handler that implements the blocking query logic here - https://github.com/opengyoza/opengyoza/blob/main/agent/consul/rpc.go#L361-L439. For more on the immutable radix tree implementation, see https://github.com/hashicorp/go-immutable-radix/ and https://github.com/hashicorp/go-memdb, and the general support for "watches".

### Do the client agents store any key/value entries?

No. These are always fetched via an internal RPC request to an OpenGyoza server. The agent doesn't do any caching, and if you want to be able to fetch these values even if there's no cluster leader, then you can use a more relaxed [consistency mode](/api/index.html#consistency-modes). You can see an example where the `/v1/kv/<key>` HTTP endpoint on the agent makes an internal RPC call here - https://github.com/opengyoza/opengyoza/blob/main/agent/kvs_endpoint.go#L56-L90.

### I don't want to run an OpenGyoza agent on every node, can I just run servers with a load balancer in front?

We strongly recommend running the OpenGyoza agent on each node in a cluster. Even the key/value store benefits from having agents on each node. For example, when you lock a key it's done through a [session](/docs/internals/sessions.html), which has a lifetime that's by default tied to the health of the agent as determined by OpenGyoza's gossip-based distributed failure detector. If the agent dies, the session will be released automatically, allowing some other process to quickly see that and obtain the lock without having to wait for an open-ended TTL to expire. If you are using OpenGyoza's service discovery features, the local agent runs the health checks for each service registered on that node and only needs to send edge-triggered updates to the OpenGyoza servers (because gossip will determine if the agent itself dies). Most attempts to avoid running an agent on each node will face solving issues that are already solved by OpenGyoza's design if the agent is deployed as intended.

For cases where you really cannot run an agent alongside a service, such as for monitoring an [external service](/docs/guides/external.html), there's a companion project called the [Consul External Service Monitor](https://github.com/hashicorp/consul-esm) that may help.
