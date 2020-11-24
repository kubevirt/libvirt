#!/bin/bash

set -xe

source hack/common.sh

docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}"

tag="${IMAGE_NAME}:${IMAGE_TAG}"
platform="${DOCKER_PLATFORMS}"

# This builds a multi-architecture image and uploads it, all in a
# single step. The cached layers from the build step will be reused,
# so ultimately this only assembles and pushes the manifest
push_container "${tag}" "${platform}" BUILDER_BUILDX PUSH_REGISTRY
