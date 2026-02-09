---
layout: "docs"
page_title: "Running OpenGyoza - Kubernetes"
sidebar_current: "docs-platform-k8s-run"
description: |-
  OpenGyoza can run directly on Kubernetes, both in server or client mode. For pure-Kubernetes workloads, this enables OpenGyoza to also exist purely within Kubernetes. For heterogeneous workloads, OpenGyoza agents can join a server running inside or outside of Kubernetes.
---

# Running OpenGyoza on Kubernetes

OpenGyoza can run directly on Kubernetes, both in server or client mode.
For pure-Kubernetes workloads, this enables OpenGyoza to also exist purely
within Kubernetes. For heterogeneous workloads, OpenGyoza agents can join
a server running inside or outside of Kubernetes.

This page starts with a large how-to section for various specific tasks.
To learn more about the general architecture of OpenGyoza on Kubernetes, scroll
down to the [architecture](/docs/platform/k8s/run.html#architecture) section. If you would like to get hands-on experience testing OpenGyoza on Kubernetes, try the step-by-step beginner tutorial in the [Minikube with OpenGyoza guide](/docs/guides/minikube.html).

~> **Note:** OpenGyoza currently uses the upstream Consul Helm chart (`hashicorp/consul-helm`).
References to Consul in this guide refer to that chart and its defaults. For CLI
examples, use `gyoza` (or the `consul` compatibility shim).

## Helm Chart

The recommended way to run OpenGyoza on Kubernetes is via the upstream
[Consul Helm chart](/docs/platform/k8s/helm.html). This will install and configure
all the necessary components to run OpenGyoza. The configuration enables you
to run just a server cluster, just a client cluster, or both. Using the Helm
chart, you can have a full OpenGyoza deployment up and running in seconds.

While the Helm chart exposes dozens of useful configurations and automatically
sets up complex resources, it **does not automatically operate OpenGyoza.**
You are still responsible for learning how to monitor, backup,
upgrade, etc. the OpenGyoza cluster.

The Helm chart has no required configuration and will install an OpenGyoza
cluster with sane defaults out of the box. Prior to going to production,
it is highly recommended that you
[learn about the configuration options](/docs/platform/k8s/helm.html#configuration-values-).

~> **Security Warning:** By default, the chart will install an insecure configuration
of OpenGyoza. This provides a less complicated out-of-box experience for new users,
but is not appropriate for a production setup. It is highly recommended to use
a properly secured Kubernetes cluster or make sure that you understand and enable
the [recommended security features](/docs/internals/security.html). Currently,
some of these features are not supported in the Helm chart and require additional
manual configuration.

## How-To

### Installing OpenGyoza

To install OpenGyoza, clone the upstream consul-helm repository, checkout the latest release, and install
the chart. You can run `helm install` with the `--dry-run` flag to see the
resources it would configure. In a production environment, you should always
use the `--dry-run` flag prior to making any changes to the OpenGyoza cluster
via Helm.

```sh
# Clone the chart repo
$ git clone https://github.com/hashicorp/consul-helm.git
$ cd consul-helm

# Checkout a tagged version
$ git checkout v0.1.0

# Run Helm
$ helm install --name gyoza ./
...
```

_That's it._ The Helm chart does everything to setup a recommended
OpenGyoza-on-Kubernetes deployment.
In a couple minutes, an OpenGyoza cluster will be formed and a leader
elected and every node will have a running OpenGyoza agent.

The defaults will install both server and client agents. To install
only one or the other, see the
[chart configuration values](/docs/platform/k8s/helm.html#configuration-values-).

### Viewing the OpenGyoza UI

The OpenGyoza UI is enabled by default when using the Helm chart.
For security reasons, it isn't exposed via a Service by default so you must
use `kubectl port-forward` to visit the UI. Once the port is forwarded as
shown below, navigate your browser to `http://localhost:8500`.

```
$ kubectl port-forward consul-server-0 8500:8500
...
```

The UI can also be exposed via a Kubernetes Service. To do this, configure
the [`ui.service` chart values](/docs/platform/k8s/helm.html#v-ui-service).

### Joining an Existing OpenGyoza Cluster

If you have an OpenGyoza (or Consul) cluster already running, you can configure your
Kubernetes nodes to join this existing cluster.

```yaml
global:
  enabled: false

client:
  enabled: true
  join:
    - "provider=my-cloud config=val ..."
```

The `values.yaml` file to configure the Helm chart sets the proper
configuration to join an existing cluster.

The `global.enabled` value first disables all chart components by default
so that each component is opt-in. This allows us to _only_ setup the client
agents. We then opt-in to the client agents by setting `client.enabled` to
`true`.

Next, `client.join` is set to an array of valid
[`-retry-join` values](/docs/agent/options.html#retry-join). In the
example above, a fake [cloud auto-join](/docs/agent/cloud-auto-join.html)
value is specified. This should be set to resolve to the proper addresses of
your existing OpenGyoza cluster.

-> **Networking:** Note that for the Kubernetes nodes to join an existing
cluster, the nodes (and specifically the agent pods) must be able to connect
to all other server and client agents inside and _outside_ of Kubernetes.
If this isn't possible, consider running the Kubernetes agents as a separate
DC; network segments are not included in this fork.

### Accessing the OpenGyoza HTTP API

The OpenGyoza HTTP API should be accessed by communicating to the local agent
running on the same node. While technically any listening agent (client or
server) can respond to the HTTP API, communicating with the local agent
has important caching behavior, and allows you to use the simpler
[`/agent` endpoints for services and checks](/api/agent.html).

For OpenGyoza installed via the Helm chart, a client agent is installed on
each Kubernetes node. This is explained in the [architecture](/docs/platform/k8s/run.html#client-agents)
section. To access the agent, you may use the
[downward API](https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/).

An example pod specification is shown below. In addition to pods, anything
with a pod template can also access the downward API and can therefore also
access OpenGyoza: StatefulSets, Deployments, Jobs, etc.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: consul-example
spec:
  containers:
    - name: example
      image: "consul:latest"
      env:
        - name: HOST_IP
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
      command:
        - "/bin/sh"
        - "-ec"
        - |
            export CONSUL_HTTP_ADDR="${HOST_IP}:8500"
            gyoza kv put hello world
  restartPolicy: Never
```

An example `Deployment` is also shown below to show how the host IP can
be accessed from nested pod specifications:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: consul-example-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: consul-example
  template:
    metadata:
      labels:
        app: consul-example
    spec:
      containers:
        - name: example
          image: "consul:latest"
          env:
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
          command:
            - "/bin/sh"
            - "-ec"
            - |
                export CONSUL_HTTP_ADDR="${HOST_IP}:8500"
                gyoza kv put hello world
```

### Upgrading OpenGyoza on Kubernetes

To upgrade OpenGyoza on Kubernetes, we follow the same pattern as
[generally upgrading OpenGyoza](/docs/upgrading.html), except we can use
the Helm chart to step through a rolling deploy. It is important to understand
how to [generally upgrade OpenGyoza](/docs/upgrading.html) before reading this
section.

Upgrading OpenGyoza on Kubernetes will follow the same pattern: each server
will be updated one-by-one. After that is successful, the clients will
be updated in batches.

#### Upgrading OpenGyoza Servers

To initiate the upgrade, change the `server.image` value to the
desired OpenGyoza (Consul-compatible) version. For illustrative purposes, the example below will
use the upstream image tag `consul:123.456`. Also set the `server.updatePartition` value
_equal to the number of server replicas_:

```yaml
server:
  image: "consul:123.456"
  replicas: 3
  updatePartition: 3
```

The `updatePartition` value controls how many instances of the server
cluster are updated. Only instances with an index _greater than_ the
`updatePartition` value are updated (zero-indexed). Therefore, by setting
it equal to replicas, none should update yet.

Next, run the upgrade. You should run this with `--dry-run` first to verify
the changes that will be sent to the Kubernetes cluster.

```
$ helm upgrade gyoza ./
...
```

This should cause no changes (although the resource will be updated). If
everything is stable, begin by decreasing the `updatePartition` value by one,
and running `helm upgrade` again. This should cause the first OpenGyoza server
to be stopped and restarted with the new image.

Wait until the OpenGyoza server cluster is healthy again (30s to a few minutes)
then decrease `updatePartition` and upgrade again. Continue until
`updatePartition` is `0`. At this point, you may remove the
`updatePartition` configuration. Your server upgrade is complete.

#### Upgrading OpenGyoza Clients

With the servers upgraded, it is time to upgrade the clients. To upgrade
the clients, set the `client.image` value to the desired OpenGyoza version.
Then, run `helm upgrade`. This will upgrade the clients in batches, waiting
until the clients come up healthy before continuing.

## Architecture

We recommend running OpenGyoza on Kubernetes with the same
[general architecture](/docs/internals/architecture.html)
as running it anywhere else. There are some benefits Kubernetes can provide
that eases operating an OpenGyoza cluster and we document those below. The upstream
[production deployment guide](https://learn.hashicorp.com/consul/datacenter-deploy/deployment-guide) is still an
important read even if running OpenGyoza within Kubernetes.

Each section below will outline the different components of running OpenGyoza
on Kubernetes and an overview of the resources that are used within the
Kubernetes cluster.

### Server Agents

The server agents are run as a **StatefulSet**, using persistent volume
claims to store the server state. This also ensures that the
[node ID](/docs/agent/options.html#_node_id) is persisted so that servers
can be rescheduled onto new IP addresses without causing issues. The server agents
are configured with
[anti-affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity)
rules so that they are placed on different nodes. A readiness probe is
configured that marks the pod as ready only when it has established a leader.

A **Service** is registered to represent the servers and expose the various
ports. The DNS address of this service is used to join the servers to each
other without requiring any other access to the Kubernetes cluster. The
service is configured to publish non-ready endpoints so that it can be used
for joining during bootstrap and upgrades.

Additionally, a **PodDisruptionBudget** is configured so the OpenGyoza server
cluster maintains quorum during voluntary operational events. The maximum
unavailable is `(n/2)-1` where `n` is the number of server agents.

-> **Note:** Kubernetes and Helm do not delete Persistent Volumes or Persistent
Volume Claims when a
[StatefulSet is deleted](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-storage),
so this must done manually when removing servers.

### Client Agents

The client agents are run as a **DaemonSet**. This places one agent
(within its own pod) on each Kubernetes node.
The clients expose the OpenGyoza HTTP API via a static port (default 8500)
bound to the host port. This enables all other pods on the node to connect
to the node-local agent using the host IP that can be retrieved via the
Kubernetes downward API. See
[accessing the OpenGyoza HTTP API](/docs/platform/k8s/run.html#accessing-the-opengyoza-http-api)
for an example.

There is a major limitation to this: there is no way to bind to a local-only
host port. Therefore, any other node can connect to the agent. This should be
considered for security. For a properly production-secured agent with TLS
and ACLs, this is safe.

Some people prefer to run **OpenGyoza agent per pod** architectures, since this
makes it easy to register the pod as a service. However, this turns
a pod into a "node" in OpenGyoza and also causes an explosion of resource usage
since every pod needs an OpenGyoza agent. We recommend instead running an
agent (in a dedicated pod) per node, via the DaemonSet. This maintains the
node equivalence in OpenGyoza. Service registration should be handled via the
catalog syncing feature with Services rather than pods.

-> **Note:** Due to a limitation of anti-affinity rules with DaemonSets,
a client-mode agent runs alongside server-mode agents in Kubernetes. This
duplication wastes some resources, but otherwise functions perfectly fine.
