---
layout: "docs"
page_title: "Out-of-Cluster Nodes - Kubernetes"
sidebar_current: "docs-platform-k8s-ooc-nodes"
description: |-
  Non-Kubernetes nodes can join an OpenGyoza cluster running within Kubernetes. These are considered "out-of-cluster" nodes.
---

# Out-of-Cluster Nodes

Non-Kubernetes nodes can join an OpenGyoza cluster running within Kubernetes.
These are considered "out-of-cluster" nodes.

~> **Note:** OpenGyoza uses the upstream Consul Helm chart. Labels, annotations,
and DNS domains still use the `consul` prefix for compatibility.

## Auto-join

The recommended way to join a cluster running within Kubernetes is to
use the ["k8s" cloud auto-join provider](/docs/agent/cloud-auto-join.html#kubernetes-k8s-).

The auto-join provider dynamically discovers IP addresses to join using
the Kubernetes API. It authenticates with Kubernetes using a standard
`kubeconfig` file. This works with all major hosted Kubernetes offerings
as well as self-hosted installations.

The auto-join string below will join an OpenGyoza server cluster that is
started using the [official Helm chart](/docs/platform/k8s/helm.html):

```sh
$ gyoza agent -retry-join 'provider=k8s label_selector="app=consul,component=server"'
```

By default, OpenGyoza will join the default Gossip port. Pods may set an
annotation `consul.hashicorp.com/auto-join-port` to an integer value or
a named port to specify the port for the auto-join to return. This enables
different pods to have different exposed ports.

## Networking

OpenGyoza typically requires a fully connected network. Therefore, out-of-cluster
nodes joining a cluster running within Kubernetes must be able to communicate
to pod IPs or Kubernetes node IPs via the network.

-> Network segments can enable non-fully-connected topologies but are not
included in this fork. However,
out-of-cluster nodes must still be able to communicate with the server pod or
host IP addresses.

The auto-join provider discussed above will use pod IPs by default. The
`host_network=true` setting may be set to use host IPs, however all the ports
OpenGyoza requires must be exposed via a `hostPort`. If no ports are exposed via
`hostPort`, the pod will not be discovered.
