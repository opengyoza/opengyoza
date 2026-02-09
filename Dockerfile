# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# docker.io/library/busybox:1.36.0
# When pinning use the multi-arch manifest list, `docker buildx imagetools inspect ...`
FROM docker.io/library/busybox@sha256:9e2bbca079387d7965c3a9cee6d0c53f4f4e63ff7637877a83c4c05f2a666112 as release

ARG PRODUCT_NAME=gyoza
ARG PRODUCT_VERSION
ARG PRODUCT_REVISION
# TARGETARCH and TARGETOS are set automatically when --platform is provided.
ARG TARGETOS TARGETARCH
ARG ARTIFACT_DIR=pkg/bin

LABEL maintainer="OpenGyoza Team <opengyoza@users.noreply.github.com>"
LABEL version=${PRODUCT_VERSION}
LABEL revision=${PRODUCT_REVISION}

COPY ${ARTIFACT_DIR}/${TARGETOS}_${TARGETARCH}/gyoza /bin/gyoza
COPY ${ARTIFACT_DIR}/${TARGETOS}_${TARGETARCH}/consul /bin/consul
COPY ./scripts/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["help"]
