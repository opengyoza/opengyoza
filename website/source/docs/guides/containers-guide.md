---
name: 'OpenGyoza with Containers'
content_length: 15
id: containers-guide
layout: content_layout
products_used:
  - OpenGyoza
description: OpenGyoza can be run in containers; this guide demonstrates basic usage and notes upstream Consul image compatibility.
level: Implementation
---

# OpenGyoza with Containers

~> This guide is adapted from upstream Consul documentation. Container image names
   and `/consul` filesystem paths are preserved for compatibility; use OpenGyoza
   images and binaries where available.

In this guide, you will learn how to deploy two, joined OpenGyoza agents each running in separate Docker containers. You will also register a service and perform basic maintenance operations. The two OpenGyoza agents will form a small datacenter. 

By following this guide you will learn how to:

1. Get the Docker image for OpenGyoza
1. Configure and run an OpenGyoza server
1. Configure and run an OpenGyoza client
1. Interact with the OpenGyoza agents
1. Perform maintenance operations (backup your OpenGyoza data, stop an OpenGyoza agent, etc.)

The guide is Docker-focused, but the principles you will learn apply to other container runtimes as well. 

!> Security Warning This guide is not for production use. Please refer to the [OpenGyoza Reference Architecture](/docs/guides/deployment.html) for OpenGyoza best practices and the [Docker Documentation](https://docs.docker.com/) for Docker best practices.

## Prerequisites

### Docker

You will need a local install of Docker running on your machine for this guide. You can find the instructions for installing Docker on your specific operating system [here](https://docs.docker.com/install/).

### OpenGyoza (Optional)

If you would like to interact with your containerized OpenGyoza agents using a local install of OpenGyoza, follow the instructions [here](/docs/install/index.html) and install the binary somewhere on your PATH.

## Get the Docker Image

First, pull the latest image. Use the OpenGyoza image (or the upstream Consul image if that is what you have available).

```sh
$ docker pull gyoza
```

Check the image was downloaded by listing Docker images that match `gyoza`.

```sh
$ docker images -f 'reference=gyoza'
REPOSITORY     TAG      IMAGE ID        CREATED             SIZE
gyoza         latest   c836e84db154     4 days ago         107MB
```
## Configure and Run an OpenGyoza Server

Next, you will use Docker command-line flags to start the agent as a server, configure networking, and bootstrap the datacenter when one server is up.

```sh
$ docker run \
    -d \
    -p 8500:8500 \
    -p 8600:8600/udp \
    --name=badger \
    gyoza agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0
```

Since you started the container in detached mode, `-d`, the process will run in the background. You also set port mapping to your local machine as well as binding the client interface of our agent to 0.0.0.0. This allows you to work directly with the OpenGyoza datacenter from your local machine and to access the OpenGyoza UI and DNS over localhost. Finally, you are using Docker's default bridge network.

Note, the container image sets up the configuration directory at `/consul/config` by default. The agent will load any configuration files placed in that directory. 

~> The configuration directory is **not** exposed as a volume and will not persist data. OpenGyoza uses it only during startup and does not store any state there. 

To avoid mounting volumes or copying files to the container you can also save [configuration JSON](/docs/agent/options.html#configuration-files) to that directory via the environment variable `CONSUL_LOCAL_CONFIG`.


### Discover the Server IP Address

You can find the IP address of the OpenGyoza server by executing the `gyoza members` command inside of the `badger` container. 

```sh
$  docker exec badger gyoza members
Node       Address         Status    Type    Build  Protocol  DC
server-1  172.17.0.2:8301  alive     server  1.4.4  2         dc1
```

## Configure and Run an OpenGyoza Client

Next, deploy a containerized OpenGyoza client and instruct it to join the server by giving it the server's IP address. Do not use detached mode, so you can reference the client logs during later steps. 

```sh
$ docker run \
   --name=fox \
   gyoza agent -node=client-1 -join=172.17.0.2
==> Starting OpenGyoza agent...
==> Joining cluster...
    Join completed. Synced with 1 initial agents
==> OpenGyoza agent running!
           Version: 'v1.4.4'
           Node ID: '4b6da3c6-b13f-eba2-2b78-446ffa627633'
         Node name: 'client-1'
        Datacenter: 'dc1'
            Server: false (Bootstrap: false)
       Client Addr: [127.0.0.1] (HTTP: 8500, HTTPS: -1, gRPC: -1, DNS: 8600)
      Cluster Addr: 172.17.0.4 (LAN: 8301, WAN: 8302)
           Encrypt: Gossip: false, TLS-Outgoing: false, TLS-Incoming: false

```

In a new terminal, check that the client has joined by executing the `gyoza members` command again in the OpenGyoza server container. 

```sh
$  docker exec badger gyoza members
Node      Address          Status  Type    Build  Protocol  DC
server-1  172.17.0.2:8301  alive   server  1.4.3  2         dc1
client-1  172.17.0.3:8301  alive   client  1.4.3  2         dc1

```

Now that you have a small datacenter, you can register a service and 
perform maintenance operations. 

## Register a Service

Start a service in a third container and register it with the OpenGyoza client. The basic service increments a number every time it is accessed and returns that number. 

Pull the container and run it with port forwarding so that you can access it from your web browser by visiting [http://localhost:9001](http://localhost:9001).

```sh
$ docker pull hashicorp/counting-service:0.0.2
$ docker run \
   -p 9001:9001 \
   -d \
   --name=weasel \
   hashicorp/counting-service:0.0.2
```

Next, you will register the counting service with the OpenGyoza client by adding a service definition file called `counting.json` in the directory `consul/config`.

```sh
$ docker exec fox /bin/sh -c "echo '{\"service\": {\"name\": \"counting\", \"tags\": [\"go\"], \"port\": 9001}}' >> /consul/config/counting.json"
```

Since the OpenGyoza client does not automatically detect changes in the 
configuration directory, you will need to issue a reload command for the same container.

```sh
$ docker exec fox gyoza reload
Configuration reload triggered
```

If you go back to the terminal window where you started the client, you should see logs showing that the OpenGyoza client received the hangup signal, reloaded its configuration, and synced the counting service.

```sh
2019/07/01 21:49:49 [INFO] agent: Caught signal:  hangup
2019/07/01 21:49:49 [INFO] agent: Reloading configuration...
2019/07/01 21:49:49 [INFO] agent: Synced service "counting"
```

### Use OpenGyoza DNS to Discover the Service

Now you can query OpenGyoza for the location of your service using the following dig command against OpenGyoza's DNS (`.consul` domain).

```sh
$ dig @127.0.0.1 -p 8600 counting.service.consul

; <<>> DiG 9.10.6 <<>> @127.0.0.1 -p 8600 counting.service.consul
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 47570
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;counting.service.consul.       IN      A

;; ANSWER SECTION:
counting.service.consul. 0      IN      A       172.17.0.3

;; Query time: 1 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Tue Jul 02 09:02:38 PDT 2019
;; MSG SIZE  rcvd: 104
```

You can also see your newly registered service in the OpenGyoza UI, [http://localhost:8500](http://localhost:8500).

![OpenGyoza UI with Registered Service](/assets/images/consul-containers-ui-services.png 'OpenGyoza UI with Registered Service')

## OpenGyoza Container Maintenance Operations

### Accessing Containers

You can access a containerized OpenGyoza datacenter in several different ways. 

#### Docker Exec

You can execute OpenGyoza commands directly inside of your OpenGyoza containers using `docker exec`.

```sh
$ docker exec <container_id> gyoza members
Node      Address          Status  Type    Build  Protocol  DC
server-1  172.17.0.2:8301  alive   server  1.5.2  2         dc1
client-1  172.17.0.3:8301  alive   client  1.5.2  2         dc1
```

#### Docker Exec Attach

You can also issue commands inside of your container by opening an interactive shell and using the OpenGyoza binary included in the container.

```sh
$ docker exec -it <container_id> /bin/sh
/ # gyoza members
Node      Address          Status  Type    Build  Protocol  DC
server-1  172.17.0.2:8301  alive   server  1.5.2  2         dc1
client-1  172.17.0.3:8301  alive   client  1.5.2  2         dc1
```

#### Local OpenGyoza Binary

If you have a local OpenGyoza binary in your PATH you can also export the `CONSUL_HTTP_ADDR` environment variable to point to the HTTP address of a remote OpenGyoza server. This will allow you to bypass `docker exec <container_id> gyoza <command>` and use `gyoza <command>` directly. 

```sh
$ export CONSUL_HTTP_ADDR=<consul_server_ip>:8500
$ gyoza members
Node      Address          Status  Type    Build  Protocol  DC
server-1  172.17.0.2:8301  alive   server  1.5.2  2         dc1
client-1  172.17.0.3:8301  alive   client  1.5.2  2         dc1
```

In this guide, you are binding your containerized OpenGyoza server's client address to 0.0.0.0 which allows us to communicate with our OpenGyoza datacenter with a local OpenGyoza install. By default, the client address is bound to localhost.

```sh
$ which gyoza
/usr/local/bin/gyoza
$ gyoza members
Node      Address          Status  Type    Build  Protocol  DC
server-1  172.17.0.2:8301  alive   server  1.5.2  2         dc1
client-1  172.17.0.3:8301  alive   client  1.5.2  2         dc1
```

### Stopping, Starting, and Restarting Containers

The official upstream Consul container supports stopping, starting, and restarting. To stop a container, run `docker stop`.

```sh
$ docker stop <container_id>
```

To start a container, run `docker start`.

```sh
$ docker start <container_id>
```

To do an in-memory reload, send a SIGHUP to the container.

```sh
$ docker kill --signal=HUP <container_id>
```

### Removing Servers from the Datacenter

As long as there are enough servers in the datacenter to maintain [quorum](/docs/internals/consensus.html#deployment-table), OpenGyoza's [autopilot](/docs/guides/autopilot.html) feature will handle removing servers whose containers were stopped. Autopilot's default settings are already configured correctly. If you override them, make sure that the following [settings](/docs/agent/options.html#autopilot) are appropriate.

* `cleanup_dead_servers` must be set to true to make sure that a stopped container is removed from the datacenter.
* `last_contact_threshold` should be reasonably small, so that dead servers are removed quickly.
* `server_stabilization_time` should be sufficiently large (on the order of several seconds) so that unstable servers are not added to the datacenter until they stabilize.

If the container running the currently-elected OpenGyoza server leader is stopped, a leader election will be triggered.

When a previously stopped server container is restarted using `docker start <container_id>`,  and it is configured to obtain a new IP, autopilot will add it back to the set of Raft peers with the same node-id and the new IP address, after which it can participate as a server again.


### Backing-up Data

You can back-up your OpenGyoza datacenter using the [gyoza snapshot](/docs/commands/snapshot.html) command. 

```sh
$ docker exec <container_id> gyoza snapshot save backup.snap
```

This will leave the `backup.snap` snapshot file inside of your container. If you are not saving your snapshot to a [persistent volume](https://docs.docker.com/storage/volumes/) then you will need to use `docker cp` to move your snapshot to a location outside of your container.

```sh
$ docker cp <container_id>:backup.snap ./ 
```

### Environment Variables

You can add configuration by passing the configuration JSON via the environment variable `CONSUL_LOCAL_CONFIG`. 

```sh
$ docker run \
	-d \
	-e CONSUL_LOCAL_CONFIG='{
	"datacenter":"us_west",
	"server":true,
	"enable_debug":true
	}' \
	gyoza agent -server -bootstrap-expect=3
```

Setting `CONSUL_CLIENT_INTERFACE` or `CONSUL_BIND_INTERFACE` on `docker run` is equivalent to passing in the `-client` flag(documented [here](/docs/agent/options.html#_client)) or `-bind` flag(documented [here](/docs/agent/options.html#_bind)) to OpenGyoza on startup.

Setting the `CONSUL_ALLOW_PRIVILEGED_PORTS` runs setcap on the OpenGyoza binary, allowing it to bind to privileged ports. Note that not all Docker storage backends support this feature (notably AUFS). 

```sh
$ docker run -d --net=host -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' gyoza -dns-port=53 -recursor=8.8.8.8
```

## Summary

In this guide you learned to deploy a containerized OpenGyoza datacenter. You also learned how to deploy a containerized service and how to configure your OpenGyoza client to register that service with your OpenGyoza datacenter.

You can continue learning how to deploy an OpenGyoza datacenter in production by completing the [Deployment Guide](/docs/guides/deployment-guide.html). It covers securing the datacenter with Access Control Lists and encryption, DNS configuration, and datacenter federation.

For additional reference documentation on the official Docker image for Consul, refer to the following websites:

- [OpenGyoza Documentation](/docs/index.html)
- [Docker Documentation](https://docs.docker.com/)
- [Consul @ Dockerhub](https://hub.docker.com/_/consul)
- [hashicorp/docker-consul GitHub Repository](https://github.com/hashicorp/docker-consul)
