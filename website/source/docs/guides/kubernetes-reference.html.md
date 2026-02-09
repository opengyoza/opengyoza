--- 
layout: "docs"
page_title: "Kubernetes OpenGyoza Reference Architecture"
sidebar_current: "docs-guides-k8s-reference-architecture"
description: |-
  This document provides recommended practices and a reference architecture. 
---

# OpenGyoza and Kubernetes Reference Architecture

Preparing your Kubernetes cluster to successfully deploy and run OpenGyoza is an
important first step in your production deployment process. In this guide you
will prepare your Kubernetes cluster, that can be running on any platform
(AKS, EKS, GKE, etc). However, we will call out cloud specific differences when
applicable. Before starting this guide you should have experience with
Kubernetes, and have `kubectl` and helm configured locally. 

By the end of this guide, you will be able to select the right resource limits
for OpenGyoza pods, select the OpenGyoza datacenter design that meets your use case,
and understand the minimum networking requirements. 

## Infrastructure Requirements

OpenGyoza server agents are responsible for the cluster state, responding to RPC
queries, and processing all write operations. Since the OpenGyoza servers are
highly active and are responsible for maintaining the cluster state, server
sizing is critical for the overall performance, efficiency, and health of the
OpenGyoza cluster. Review the [OpenGyoza Reference
Architecture](/docs/guides/deployment.html#opengyoza-servers)
guide for sizing recommendations for small and large OpenGyoza datacenters. 

The CPU and memory recommendations can be used when you select the resources
limits for the OpenGyoza pods. The disk recommendations can also be used when
selecting the resources limits and configuring persistent volumes. You will
need to set both `limits` and `requests` in the Helm chart. Below is an example
snippet of Helm config for an OpenGyoza server in a large environment.

```yaml
# values.yaml

server 
  resources: | 
    requests: 
      memory: "32Gi" 
      cpu: "4" 
    limits: 
      memory: "32Gi"
      cpu: "4"

  storage: 50Gi
...
```

You should also set [resource limits for OpenGyoza
clients](/docs/platform/k8s/helm.html#v-client-resources),
so that the client pods do not unexpectedly consume more resources than
expected. 

[Persistent
volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) (PV)
allow you to have a fixed disk location for the OpenGyoza data. This ensures that
if an OpenGyoza server is lost, the data will not be lost. This is an important
feature of Kubernetes, but may take some additional configuration. If you are
running Kubernetes on one of the major cloud platforms, persistent volumes
should already be configured for you; be sure to read their documentation for more
details. If you are setting up the persistent volumes resource in Kubernetes, you may need
to map the OpenGyoza server to that volume with the [storage class
parameter](/docs/platform/k8s/helm.html#v-server-storageclass).

Finally, you will need to enable RBAC on your Kubernetes cluster. Review
the [Kubernetes
RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) documenation. You
should also review RBAC and authentication documentation if your Kubernetes cluster
is running on a major cloud platorom.

- [AWS](https://docs.aws.amazon.com/eks/latest/userguide/managing-auth.html).
- [GCP](https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control).
- [Azure](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create). In Azure, RBAC is enabled by default. 

## Datacenter Design 

There are many possible configurations for running OpenGyoza with Kubernetes. In this guide
we will cover three of the most common.

1. OpenGyoza agents can be solely deployed within Kubernetes.  
1. OpenGyoza servers
can be deployed outside of Kubernetes and clients inside of Kubernetes.  
1. Multiple OpenGyoza datacenters with agents inside and outside of Kubernetes.  

Review the OpenGyoza Kubernetes-specific
[documentation](/docs/platform/k8s/index.html#use-cases)
for additional use case information. 

Since all three use cases will also need catalog sync, review the
implementation [details for catalog sync](/docs/platform/k8s/service-sync.html).  

### OpenGyoza Datacenter Deployed in Kubernetes 

Deploying an OpenGyoza cluster, servers and clients, in Kubernetes can be done with
the official [Helm
chart](/docs/platform/k8s/helm.html#using-the-helm-chart).
This configuration is useful for managing services within Kubernetes and is
common for users who do not already have a production OpenGyoza datacenter.

![Reference Diagram](/assets/images/k8s-consul-simple.png "OpenGyoza in Kubernetes Reference Diagram")

The OpenGyoza datacenter in Kubernetes will function the same as a platform
independent OpenGyoza datacenter, such as OpenGyoza clusters deployed on bare metal servers
or virtual machines. Agents will communicate over LAN gossip, servers
will participate in the Raft consensus, and client requests will be
forwarded to the servers via RPCs.

### OpenGyoza Datacenter with a Kubernetes Cluster

To use an existing OpenGyoza cluster to manage services in Kubernetes, OpenGyoza
clients can be deployed within the Kubernetes cluster. This will also allow
Kubernetes-defined services to be synced to OpenGyoza. This design allows OpenGyoza tools
such as envconsul, consul-template, and more to work on Kubernetes. 

![Reference Diagram](/assets/images/k8s-cluster-consul-datacenter.png "OpenGyoza and Kubernetes Reference Diagram")

This type of deployment in Kubernetes can also be set up with the official Helm
chart.


### Multiple OpenGyoza Clusters with a Kubernetes Cluster

OpenGyoza clusters in different datacenters running the same service can be joined
by WAN links. The clusters can operate independently and only communicate over
the WAN. This type datacenter design is detailed in the [Reference Architecture
guide](/docs/guides/deployment.html#multiple-datacenters).
In this setup, you can have an OpenGyoza cluster running outside of Kubernetes and
a OpenGyoza cluster running inside of Kubernetes. 

### Catalog Sync

To use catalog sync, you must enable it in the [Helm
chart](/docs/platform/k8s/helm.html#v-synccatalog).
Catalog sync allows you to sync services between OpenGyoza and Kubernetes. The
sync can be unidirectional in either direction or bidirectional. Read the
[documentation](/docs/platform/k8s/service-sync.html) to
learn more about the configuration. 

Services synced from Kubernetes to OpenGyoza will be discoverable, like any other
service within the OpenGyoza datacenter. Read more in the [network
connectivity](#networking-connectivity) section to learn more about related
Kubernetes configuration. Services synced from OpenGyoza to Kubernetes will be
discoverable with the built-in Kubernetes DNS once a [OpenGyoza stub
domain](/docs/platform/k8s/dns.html) is deployed. When
bidirectional catalog sync is enabled, it will behave like the two
unidirectional setups. 

## Networking Connectivity 

When running OpenGyoza as a pod inside of Kubernetes, the OpenGyoza servers will be
automatically configured with the appropriate addresses. However, when running
OpenGyoza servers outside of the Kubernetes cluster and clients inside Kubernetes
as pods, there are additional [networking
considerations](/consul/advanced/day-1-operations/reference-architecture#network-connectivity).

### Network Connectivity for Services

When using OpenGyoza catalog sync, to sync Kubernetes services to OpenGyoza, you will
need to ensure the Kubernetes services are supported [service
types](/docs/platform/k8s/service-sync.html#kubernetes-service-types)
and configure correctly in Kubernetes. If the service is configured correctly,
it will be discoverable by OpenGyoza like any other service in the datacenter. 

~> Warning: You are responsible for ensuring that external services can communicate 
with services deployed in the Kubernetes cluster. For example, `ClusterIP` type services 
may not be directly accessible by IP address from outside the Kubernetes cluster 
for some Kubernetes configurations.

### Network Security

Finally, you should consider securing your OpenGyoza datacenter with
[ACLs](/consul/advanced/day-1-operations/production-acls). ACLs should be used with [OpenGyoza
Connect](/docs/platform/k8s/connect.html) to secure
service to service communication. The Kubernetes cluster should also be
secured. 

## Summary 

You are now prepared to deploy OpenGyoza with Kubernetes. In this
guide, you were introduced to several a datacenter design for a variety of use
cases. This guide also outlined the Kubernetes prerequisites, resource
requirements for OpenGyoza, and networking considerations. Continue onto the
[Deploying OpenGyoza with Kubernetes
guide](/consul/getting-started-k8s/helm-deploy) for
information on deploying OpenGyoza with the official Helm chart or continue
reading about OpenGyoza Operations in the [Day 1 Path](https://learn.hashicorp.com/consul/?track=advanced#advanced). 
 
