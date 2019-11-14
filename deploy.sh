#!/bin/bash

set -xe

source config

GIT_UNIX_TIMESTAMP=$(git show --format='%ct' | head -1)
GIT_TIMESTAMP=$(date --date="@${GIT_UNIX_TIMESTAMP}" '+%Y%m%d')
GIT_COMMIT=$(git describe --always)
HOST_ARCH=$(uname -m)
TAG="${GIT_TIMESTAMP}.${GIT_COMMIT}"

# Manifests are still not enabled by default, so we need to turn on
# experimental features in order to use them
mkdir -p ~/.docker
cp docker-config.json ~/.docker/config.json

docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}"

docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${TAG}.${HOST_ARCH}"
docker push "${IMAGE_NAME}:${TAG}.${HOST_ARCH}"

# We need one of the workers to stick around so that it can create
# and push the manifest, as well as clean up. It doesn't really
# matter which one does it but based on observation the ppc64le
# build is usually the last to finish, so by having that one stick
# around we don't introduce any artificial delays
if test "${HOST_ARCH}" != "ppc64le"; then
    exit 0
fi

# Wait for the other images to be available before proceeding
while true; do
    docker pull "${IMAGE_NAME}:${TAG}.x86_64" && break
    sleep 5
done

docker manifest create \
    "${IMAGE_NAME}:${TAG}" \
    "${IMAGE_NAME}:${TAG}.x86_64" \
    "${IMAGE_NAME}:${TAG}.ppc64le"
docker manifest push "${IMAGE_NAME}:${TAG}"

docker manifest create \
    "${IMAGE_NAME}:latest" \
    "${IMAGE_NAME}:${TAG}.x86_64" \
    "${IMAGE_NAME}:${TAG}.ppc64le"
docker manifest push "${IMAGE_NAME}:latest"

# Remove architecture-specific tags: we no longer need them
bash rmtag.sh "${DOCKER_USER}" "${DOCKER_PASS}" "${TAG}.x86_64"
bash rmtag.sh "${DOCKER_USER}" "${DOCKER_PASS}" "${TAG}.ppc64le"
