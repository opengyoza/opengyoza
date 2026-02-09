---
layout: "docs"
page_title: "Kubernetes"
sidebar_current: "docs-platform-k8s-index"
description: |-
  OpenGyoza has many integrations with Kubernetes. You can deploy OpenGyoza to Kubernetes using the upstream Helm chart, sync services between OpenGyoza and Kubernetes, automatically secure Pod communication with Connect, and more. This section documents the official integrations between OpenGyoza and Kubernetes.
---

# Kubernetes

OpenGyoza has many integrations with Kubernetes. You can deploy OpenGyoza
to Kubernetes using the upstream Helm chart, sync services between OpenGyoza and
Kubernetes, automatically secure Pod communication with Connect, and more.
This section documents the official integrations between OpenGyoza and Kubernetes.

~> **Note:** OpenGyoza uses the upstream `consul-k8s` components and Consul Helm
chart. Repository names, chart defaults, and some resource names still use the
`consul` prefix for compatibility.

## Use Cases

**Running an OpenGyoza server cluster:** The OpenGyoza server cluster can run directly
on Kubernetes. This can be used by both nodes within Kubernetes as well as
nodes external to Kubernetes, as long as they can communicate to the server
nodes via the network.

**Running OpenGyoza clients:** OpenGyoza clients can run as pods on every node
and expose the OpenGyoza API to running pods. This enables many OpenGyoza tools
such as envconsul, consul-template, and more to work on Kubernetes since a
local agent is available. This will also register each Kubernetes node with
the OpenGyoza catalog for full visibility into your infrastructure.

**Service sync to enable Kubernetes and non-Kubernetes services to communicate:**
OpenGyoza can sync Kubernetes services with its own service registry. This allows
Kubernetes services to use native Kubernetes service discovery to discover
and connect to external services, and for external services to use OpenGyoza
service discovery to discover and connect to Kubernetes services.

**Automatic encryption and authorization for pod network connections:**
OpenGyoza can automatically inject the [Connect](/docs/connect/index.html)
sidecar into pods so that they can accept and establish encrypted
and authorized network connections via mutual TLS. And because Connect
can run anywhere, pods can also communicate with external services (and
vice versa) over a fully encrypted connection.

**And more!** OpenGyoza can run directly on Kubernetes, so in addition to the
native integrations provided by OpenGyoza itself, any other tool built for
Kubernetes can choose to leverage OpenGyoza.

## Getting Started With OpenGyoza and Kubernetes

There are several ways to try OpenGyoza with Kubernetes in different environments.

 - The upstream [Consul and minikube guide](https://learn.hashicorp.com/consul/
   getting-started-k8s/minikube?utm_source=consul.io&utm_medium=docs) is a quick walkthrough of how to deploy the official Helm chart on a local instance of Minikube. Replace `consul` with `gyoza` for CLI commands.

 - The upstream [Deploying Consul with Kubernetes guide](https://learn.hashicorp.com/
   consul/getting-started-k8s/minikube?utm_source=consul.io&utm_medium=docs)
   walks you through deploying Consul on Kubernetes with the official Helm chart and can be applied to any Kubernetes installation type. Replace `consul` with `gyoza` for CLI commands.

 - The upstream [Kubernetes on Azure guide](https://learn.hashicorp.com/consul/
   getting-started-k8s/azure-k8s?utm_source=consul.io&utm_medium=docs) is a complete walkthrough on how to deploy Consul on AKS. Replace `consul` with `gyoza` for CLI commands.

 - The upstream [Consul and Kubernetes Reference Architecture](
   https://learn.hashicorp.com/consul/day-1-operations/kubernetes-reference?utm_source=consul.io&utm_medium=docs) guide provides recommended practices for production. 

 - The upstream [Consul and Kubernetes Deployment](
   https://learn.hashicorp.com/consul/day-1-operations/kubernetes-deployment-guide?utm_source=consul.io&utm_medium=docs) guide covers the necessary steps to install and configure a new Consul cluster on Kubernetes in production.

## "consul-k8s" Project

The dedicated [consul-k8s project](https://github.com/hashicorp/consul-k8s)
contains the integration functionality between OpenGyoza and Kubernetes.
You generally will not need to invoke this project directly since the
[Helm chart](/docs/platform/k8s/helm.html) automates the installation and
configuration of the project when necessary.

We may integrate this functionality directly into OpenGyoza in the future,
but the separate project allows us to iterate and version the Kubernetes
functionality separately. Additionally, a lot of the functionality works
across multiple Consul versions, so you're able to update and resolve any
Kubernetes integration issues without also upgrading OpenGyoza itself which
can be more difficult.
