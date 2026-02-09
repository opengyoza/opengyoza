ARG GOLANG_VERSION=1.24.1
FROM golang:${GOLANG_VERSION}

ARG GOTOOLS="github.com/elazarl/go-bindata-assetfs/go-bindata-assetfs@latest \
   github.com/hashicorp/go-bindata/go-bindata@latest \
   github.com/mitchellh/gox@latest \
   golang.org/x/tools/cmd/cover@latest \
   golang.org/x/tools/cmd/stringer@latest"

RUN for tool in ${GOTOOLS}; do go install -v ${tool}; done && mkdir -p /consul

WORKDIR /consul
