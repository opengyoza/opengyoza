ARG CONSUL_IMAGE_VERSION=latest
FROM consul:${CONSUL_IMAGE_VERSION}
COPY gyoza /bin/gyoza
COPY consul /bin/consul
ENTRYPOINT ["/bin/gyoza"]
