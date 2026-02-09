---
layout: "docs"
page_title: "Service Sync - OpenGyoza on Kubernetes"
sidebar_current: "docs-platform-k8s-service-sync"
description: |-
  The services in Kubernetes and OpenGyoza can be automatically synced so that Kubernetes services are available to OpenGyoza agents and services in OpenGyoza can be available as first-class Kubernetes services.
---

# Syncing Kubernetes and OpenGyoza Services

The services in Kubernetes and OpenGyoza can be automatically synced so that Kubernetes
services are available to OpenGyoza agents and services in OpenGyoza can be available
as first-class Kubernetes services. This functionality is provided by the
[consul-k8s project](https://github.com/hashicorp/consul-k8s) and can be
automatically installed and configured using the
[Consul Helm chart](/docs/platform/k8s/helm.html).

~> **Note:** OpenGyoza uses the upstream `consul-k8s` components and Consul Helm
chart. Annotations, environment variables, and API names keep the `consul` prefix
for compatibility.

**Why sync Kubernetes services to OpenGyoza?** Kubernetes services synced to the
OpenGyoza catalog enable Kubernetes services to be accessed by any node that
is part of the OpenGyoza cluster, including other distinct Kubernetes clusters.
For non-Kubernetes nodes, they can access services using the standard
[OpenGyoza DNS](/docs/agent/dns.html) or HTTP API.

**Why sync OpenGyoza services to Kubernetes?** Syncing OpenGyoza services to
Kubernetes services enables non-Kubernetes services (such as external to
the cluster) to be accessed in a native Kubernetes way: using kube-dns,
environment variables, etc. This makes it very easy to automate external
service discovery, including hosted services like databases.

## Installation and Configuration

The service sync is done using an external long-running process in the
[consul-k8s project](https://github.com/hashicorp/consul-k8s). This process
can run either in or out of a Kubernetes cluster. However, running this within
the Kubernetes cluster is generally easier since it is automated using the
[Helm chart](/docs/platform/k8s/helm.html).

The OpenGyoza server cluster can run either in or out of a Kubernetes cluster.
The OpenGyoza server cluster does not need to be running on the same machine
or same platform as the sync process. The sync process needs to be configured
with the address to the OpenGyoza cluster as well as any additional access
information such as ACL tokens.

To install the sync, enable the catalog sync feature using
[Helm values](/docs/platform/k8s/helm.html#configuration-values-) and
upgrade the installation using `helm upgrade` for existing installs or
`helm install` for a fresh install.

```yaml
syncCatalog:
  enabled: true
```

This will enable services to sync _in both directions_. You can also choose
to only sync Kubernetes services to OpenGyoza or vice versa by disabling a direction.

To only enable syncing OpenGyoza services to Kubernetes use the config:

```yaml
syncCatalog:
  enabled: true
  toConsul: false
  toK8S: true
```

To only enable syncing Kubernetes services to OpenGyoza use:

```yaml
syncCatalog:
  enabled: true
  toConsul: true
  toK8S: false
```

See the [Helm configuration](/docs/platform/k8s/helm.html#v-synccatalog)
for more information.

### Authentication

The sync process must authenticate to both Kubernetes and OpenGyoza to read
and write services.

If running `consul-k8s` using the Helm chart then this authentication is handled for you.

If running `consul-k8s` outside of Kubernetes, a valid kubeconfig file must be provided with cluster
and authentication information. The sync process will look into the default locations
for both in-cluster and out-of-cluster authentication. If `kubectl` works,
then the sync program should work.

For OpenGyoza, if ACLs are configured on the cluster, an OpenGyoza
[ACL token](https://learn.hashicorp.com/consul/advanced/day-1-operations/acl-guide)
will need to be provided. Review the [ACL rules](/docs/agent/acl-rules.html)
when creating this token so that it only allows the necessary privileges. The catalog
sync process accepts this token by using the [`CONSUL_HTTP_TOKEN`](/docs/commands/index.html#consul_http_token)
environment variable. This token should be set as a
[Kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/#creating-your-own-secrets)
and referenced in the Helm chart.

## Kubernetes to OpenGyoza

This sync registers Kubernetes services to the OpenGyoza catalog automatically.

This enables discovery and connection to Kubernetes services using native
OpenGyoza service discovery such as DNS or HTTP. This is particularly useful for
non-Kubernetes nodes. This also causes all discoverable services to be part of
a central service catalog in OpenGyoza for further syncing into alternate
Kubernetes clusters or other platforms.

### Kubernetes Service Types

Not all Kubernetes services are externally accessible. The sync program by
default will only sync services of the following types or configurations.
If a service type is not listed below, then the sync program will ignore that
service type.

#### NodePort

[NodePort services](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport)
register a static port that every node in the K8S cluster listens on.

For NodePort services, an OpenGyoza service instance will be created for each
node that has the representative pod running. While Kubernetes configures
a static port on all nodes in the cluster, this limits the number of service
instances to be equal to the nodes running the target pods.

The service instances will be registered to the Kubernetes node name
that each instance lives on. This is guaranteed unique by Kubernetes. An
existing node entry will be used if it is already part of the OpenGyoza
cluster (for example if you're running a client agent on all Kubernetes
nodes). This allows the normal agent health checks for that node to continue
working.

#### LoadBalancer

For LoadBalancer services, a single service instance will be registered with
the external IP of the created load balancer. Because this is already a load
balancer, only one service instance will be registered with OpenGyoza rather
than registering each individual pod endpoint.

#### External IPs

Any service type may specify an
"[external IP](https://kubernetes.io/docs/concepts/services-networking/service/#external-ips)"
configuration. The external IP must be configured by some other system, but
any service discovery will resolve to this set of IP addresses rather than a
virtual IP.

If an external IP list is present, a service instance in OpenGyoza will be created
for each external IP. It is assumed that if an external IP is present that it
is routable and configured by some other system.

#### ClusterIP

ClusterIP services are synced by default as of `consul-k8s` version 0.3.0. In 
many Kubernetes clusters, ClusterIPs may not be accessible outside of the cluster,
so you may end up with services registered in OpenGyoza that are not routable. To
skip syncing ClusterIP services, set [`syncClusterIPServices`](/docs/platform/k8s/helm.html#v-synccatalog-clusterip-sync)
to `false` in the Helm chart values file.

### Sync Enable/Disable

By default, all valid services (as explained above) are synced. This default can
be changed using the [configuration](/docs/platform/k8s/helm.html#v-synccatalog-default).
Syncing can also be explicitly enabled or disabled using an
annotation:

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  annotations:
    "consul.hashicorp.com/service-sync": "false"
```

### Service Name

When a Kubernetes service is synced to OpenGyoza, the name of the service in OpenGyoza
by default will be the value of the "name" metadata on that Kubernetes service.
This makes it so that service sync works with zero configuration changes.
This can be overridden using an annotation to specify the OpenGyoza service name:

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  annotations:
    "consul.hashicorp.com/service-name": my-consul-service
```

**If a conflicting service name exists in OpenGyoza,** the sync program will
register additional instances to that same service. Therefore, services inside
and outside of Kubernetes should have different names unless you want either
side to potentially connect. This default behavior also enables gracefully
transitioning a service from outside of K8S to inside, and vice versa.

### Service Ports

When syncing the Kubernetes service to OpenGyoza, the OpenGyoza service port will be
the first defined port in the service. Additionally, all ports will be
registered in the service instance metadata with the key "port-X" where X is
the name of the port and the value is the externally accessible port.

The default service port can be overridden using an annotation:

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  annotations:
    "consul.hashicorp.com/service-port": "http"
```

The annotation value may be a name of a port (recommended) or an exact port value.

### Service Tags

A service registered in OpenGyoza from Kubernetes will always have the tag "k8s" added
to it. Additional tags can be specified with a comma-separated annotation value
as shown below. This will also automatically include the "k8s" tag which can't
be disabled. The values should be specified comma-separated without any
additional whitespace.

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  annotations:
    "consul.hashicorp.com/service-tags": "primary,foo"
```

### Service Meta

A service registered in OpenGyoza from Kubernetes will set the `external-source` key to
"kubernetes". This can be used by API consumers, the UI, CLI, etc. to filter
service instances that are set in k8s. The OpenGyoza UI (in Consul 1.2.3 and later)
will read this value to show a Kubernetes icon next to all externally
registered services from Kubernetes.

Additional metadata can be specified using annotations. The "KEY" below can be
set to any key. This allows setting multiple meta values:

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  annotations:
    "consul.hashicorp.com/service-meta-KEY": "value"
```

## OpenGyoza to Kubernetes

This syncs OpenGyoza services into first-class Kubernetes services.
The sync service will create an [`ExternalName`](https://kubernetes.io/docs/concepts/services-networking/service/#externalname)
`Service` for each OpenGyoza service. The "external name" will be
the Consul DNS name (the `consul` domain is retained for compatibility).

For example, given an OpenGyoza service `foo`, a Kubernetes Service will be created
as follows:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: foo
  ...
spec:
  externalName: foo.service.consul
  type: ExternalName
```

With OpenGyoza to Kubernetes syncing enabled, DNS requests of the form `<consul-service-name>`
will be serviced by OpenGyoza DNS (using the `consul` domain). From a different Kubernetes
namespace than where OpenGyoza is deployed, the DNS request would need to be
`<consul-service-name>.<consul-namespace>`.

-> **Note:** OpenGyoza to Kubernetes syncing **isn't required** if you've enabled [OpenGyoza DNS on Kubernetes](/docs/platform/k8s/dns.html)
*and* all you need to do is address services in the form `<consul-service-name>.service.consul`, i.e. you don't need Kubernetes `Service` objects created.

~> **Requires OpenGyoza DNS via CoreDNS in Kubernetes:** This feature requires that
[OpenGyoza DNS](/docs/platform/k8s/dns.html) is configured within Kubernetes.
Additionally, **[CoreDNS](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/#config-coredns)
is required (instead of kube-dns)** to resolve an
issue with resolving `externalName` services pointing to custom domains.

### Sync Enable/Disable

All OpenGyoza services visible to the sync process based on its given ACL token
will be synced to Kubernetes.

There is no way to change this behavior per service. For the opposite sync
direction (Kubernetes to OpenGyoza), you can use Kubernetes annotations to disable
a sync per service. This is not currently possible for OpenGyoza to Kubernetes
sync and the ACL token must be used to limit what services are synced.

In the future, we hope to support per-service configuration.

### Service Name

When an OpenGyoza service is synced to Kubernetes, the name of the Kubernetes
service will exactly match the name of the OpenGyoza service.

To change this default exact match behavior, it is possible to specify a
prefix to be added to service names within Kubernetes by using the
`-k8s-service-prefix` flag. This can also be specified in the Helm
configuration.

**If a conflicting service is found,** the service will not be synced. This
does not match the Kubernetes to OpenGyoza behavior, but given the current
implementation we must do this because Kubernetes can't mix both CNAME and
Endpoint-based services.

### Kubernetes Service Labels and Annotations

Any OpenGyoza services synced to Kubernetes will be labeled and annotated.
An annotation `consul.hashicorp.com/synced` will be set to "true" to note
that this is a synced service from OpenGyoza.

Additionally, a label `consul=true` will be specified so that label selectors
can be used with `kubectl` and other tooling to easily filter all OpenGyoza-synced
services.
