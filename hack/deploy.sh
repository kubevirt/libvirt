#!/bin/bash

set -xe

source hack/common.sh

docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}"

# This builds a multi-architecture image and uploads it, all in a
# single step. The cached layers from the build step will be reused,
# so ultimately this only assembles and pushes the manifest
docker buildx build \
    --progress=plain \
    --push \
    --platform="${DOCKER_PLATFORM}" \
    --tag "${IMAGE_NAME}:${TAG}" \
    .
