---
layout: api
page_title: Coordinate - HTTP API
sidebar_current: api-coordinate
description: |-
  The /coordinate endpoints query for the network coordinates for nodes in the
  local datacenter as well as Consul servers in the local datacenter and remote
  datacenters.
---

# Coordinate HTTP Endpoint

The `/coordinate` endpoints query for the network coordinates for nodes in the
local datacenter as well as Consul servers in the local datacenter and remote
datacenters.

Please see the [Network Coordinates](/docs/internals/coordinates.html) internals
guide for more information on how these coordinates are computed, and for
details on how to perform calculations with them.

## Read WAN Coordinates

This endpoint returns the WAN network coordinates for all Consul servers,
organized by datacenters. It serves data out of the server's local Serf data, so
its results may vary as requests are handled by different servers in the
cluster.

| Method | Path                         | Produces                   |
| ------ | ---------------------------- | -------------------------- |
| `GET`  | `/coordinate/datacenters`    | `application/json`         |

The table below shows this endpoint's support for
[blocking queries](/api/features/blocking.html),
[consistency modes](/api/features/consistency.html),
[agent caching](/api/features/caching.html), and
[required ACLs](/api/index.html#authentication).

| Blocking Queries | Consistency Modes | Agent Caching | ACL Required |
| ---------------- | ----------------- | ------------- | ------------ |
| `NO`             | `none`            | `none`        | `none`       |

### Sample Request

```text
$ curl \
    http://127.0.0.1:8500/v1/coordinate/datacenters
```

### Sample Response

```json
[
  {
    "Datacenter": "dc1",
    "AreaID": "WAN",
    "Coordinates": [
      {
        "Node": "agent-one",
        "Coord": {
          "Adjustment": 0,
          "Error": 1.5,
          "Height": 0,
          "Vec": [0, 0, 0, 0, 0, 0, 0, 0]
        }
      }
    ]
  }
]
```

This fork does not include network areas; responses include only the default
area.

## Read LAN Coordinates for all nodes

This endpoint returns the LAN network coordinates for all nodes in a given
datacenter.

| Method | Path                         | Produces                   |
| ------ | ---------------------------- | -------------------------- |
| `GET`  | `/coordinate/nodes`          | `application/json`         |

The table below shows this endpoint's support for
[blocking queries](/api/features/blocking.html),
[consistency modes](/api/features/consistency.html),
[agent caching](/api/features/caching.html), and
[required ACLs](/api/index.html#authentication).

| Blocking Queries | Consistency Modes | Agent Caching | ACL Required |
| ---------------- | ----------------- | ------------- | ------------ |
| `YES`            | `all`             | `none`        | `node:read`  |

### Parameters

- `dc` `(string: "")` - Specifies the datacenter to query. This will default to
  the datacenter of the agent being queried. This is specified as part of the
  URL as a query parameter.

### Sample Request

```text
$ curl \
    http://127.0.0.1:8500/v1/coordinate/nodes
```

### Sample Response

```json
[
  {
    "Node": "agent-one",
    "Segment": "",
    "Coord": {
      "Adjustment": 0,
      "Error": 1.5,
      "Height": 0,
      "Vec": [0, 0, 0, 0, 0, 0, 0, 0]
    }
  }
]
```

Responses include a single coordinate for each node. The `Segment` field is present
for compatibility and is empty in this fork.

## Read LAN Coordinates for a node

This endpoint returns the LAN network coordinates for the given node.

| Method | Path                         | Produces                   |
| ------ | ---------------------------- | -------------------------- |
| `GET`  | `/coordinate/node/:node`     | `application/json`         |

The table below shows this endpoint's support for
[blocking queries](/api/features/blocking.html),
[consistency modes](/api/features/consistency.html),
[agent caching](/api/features/caching.html), and
[required ACLs](/api/index.html#authentication).

| Blocking Queries | Consistency Modes | Agent Caching | ACL Required |
| ---------------- | ----------------- | ------------- | ------------ |
| `YES`            | `all`             | `none`        | `node:read`  |

### Parameters

- `dc` `(string: "")` - Specifies the datacenter to query. This will default to
  the datacenter of the agent being queried. This is specified as part of the
  URL as a query parameter.

### Sample Request

```text
$ curl \
    http://127.0.0.1:8500/v1/coordinate/node/agent-one
```

### Sample Response

```json
[
  {
    "Node": "agent-one",
    "Segment": "",
    "Coord": {
      "Adjustment": 0,
      "Error": 1.5,
      "Height": 0,
      "Vec": [0, 0, 0, 0, 0, 0, 0, 0]
    }
  }
]
```

Responses include a single coordinate for each node. The `Segment` field is present
for compatibility and is empty in this fork.

## Update LAN Coordinates for a node

This endpoint updates the LAN network coordinates for a node in a given
datacenter.

| Method | Path                         | Produces                   |
| ------ | ---------------------------- | -------------------------- |
| `PUT`  | `/coordinate/update`         | `application/json`         |

The table below shows this endpoint's support for
[blocking queries](/api/features/blocking.html),
[consistency modes](/api/features/consistency.html),
[agent caching](/api/features/caching.html), and
[required ACLs](/api/index.html#authentication).

| Blocking Queries | Consistency Modes | Agent Caching | ACL Required |
| ---------------- | ----------------- | ------------- | ------------ |
| `NO`             | `none`            | `none`        | `node:write` |

### Parameters

- `dc` `(string: "")` - Specifies the datacenter to query. This will default to
  the datacenter of the agent being queried. This is specified as part of the
  URL as a query parameter.

### Sample Payload

```text
{
  "Node": "agent-one",
  "Segment": "",
  "Coord": {
    "Adjustment": 0,
    "Error": 1.5,
    "Height": 0,
    "Vec": [0, 0, 0, 0, 0, 0, 0, 0]
  }
}
```

### Sample Request

```text
$ curl \
    --request PUT \
    --data @payload.json \
    http://127.0.0.1:8500/v1/coordinate/update
```
