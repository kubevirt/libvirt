#!/bin/bash

set -xe

source hack/config

GIT_UNIX_TIMESTAMP=$(git show --format='%ct' | head -1)
GIT_TIMESTAMP=$(date --date="@${GIT_UNIX_TIMESTAMP}" '+%Y%m%d')
GIT_COMMIT=$(git describe --always)
TAG="${GIT_TIMESTAMP}-${GIT_COMMIT}"
DOCKER_PLATFORM="linux/$(echo "${TARGET_ARCHITECTURES}" | sed "s: :,linux/:g")"

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
