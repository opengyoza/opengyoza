#!/usr/bin/env ash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

case "$1" in
  "agent" )
    if [ -z "${CONSUL_SKIP_DOCKER_IMAGE_WARN}" ] && [ -z "${GYOZA_SKIP_DOCKER_IMAGE_WARN}" ]; then
      echo "====================================================================================="
      echo "!! Running OpenGyoza agents inside Docker containers is not supported.             !!"
      echo "!! Set GYOZA_SKIP_DOCKER_IMAGE_WARN (or CONSUL_SKIP_DOCKER_IMAGE_WARN) to skip.     !!"
      echo "====================================================================================="
      echo ""
      sleep 2
    fi
    ;;
 esac

exec gyoza "$@"
