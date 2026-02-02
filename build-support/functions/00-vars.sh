# GPG Key ID to use for publically released builds
HASHICORP_GPG_KEY="348FFC4C"

# Default Image Names
UI_BUILD_CONTAINER_DEFAULT="opengyoza-build-ui"
GO_BUILD_CONTAINER_DEFAULT="opengyoza-build-go"

# Whether to colorize shell output
COLORIZE=${COLORIZE-1}

# determine GOPATH and the first GOPATH to use for intalling binaries
GOPATH=${GOPATH:-$(go env GOPATH)}
case $(uname) in
    CYGWIN*)
        GOPATH="$(cygpath $GOPATH)"
        ;;
esac
MAIN_GOPATH=$(cut -d: -f1 <<< "${GOPATH}")

# Build debugging output is off by default
BUILD_DEBUG=${BUILD_DEBUG-0}

# default publish host is github.com - only really useful to use something else for testing
PUBLISH_GIT_HOST="${PUBLISH_GIT_HOST-github.com}"

# default publish repo is opengyoza/opengyoza - useful to override for testing
PUBLISH_GIT_REPO="${PUBLISH_GIT_REPO-opengyoza/opengyoza.git}"

# package name defaults to gyoza; allow override via CONSUL_PKG_NAME or GYOZA_PKG_NAME
GYOZA_PKG_NAME="${GYOZA_PKG_NAME-gyoza}"
CONSUL_PKG_NAME="${CONSUL_PKG_NAME-${GYOZA_PKG_NAME}}"

if test "$(uname)" == "Darwin"
then
   SED_EXT="-E"
else
   SED_EXT="-r"
fi

CONSUL_BINARY_TYPE=oss
