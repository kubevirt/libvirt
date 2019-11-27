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

docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:tmp.${TAG}.${HOST_ARCH}"
docker push "${IMAGE_NAME}:tmp.${TAG}.${HOST_ARCH}"

# We need one of the workers to stick around so that it can create
# and push the manifest, as well as clean up
if test "${HOST_ARCH}" != "${MAIN_ARCH}"; then
    exit 0
fi

TMP_IMAGES=
for ARCH in ${MAIN_ARCH} ${OTHER_ARCHES}; do
    TMP_IMAGES="${TMP_IMAGES} ${IMAGE_NAME}:tmp.${TAG}.${ARCH}"
done

# Wait for the other images to be available before proceeding
while true; do
    ALL_DONE=yes
    for TMP_IMAGE in ${TMP_IMAGES}; do
        docker pull "${TMP_IMAGE}" || ALL_DONE=no
    done
    if test "${ALL_DONE}" = "yes"; then
        break
    fi
    sleep 5
done

docker manifest create "${IMAGE_NAME}:${TAG}" ${TMP_IMAGES}
docker manifest push "${IMAGE_NAME}:${TAG}"

docker manifest create "${IMAGE_NAME}:latest" ${TMP_IMAGES}
docker manifest push "${IMAGE_NAME}:latest"

# Remove architecture-specific tags: we no longer need them
for TMP_IMAGE in ${TMP_IMAGES}; do
    bash rmtag.sh "${DOCKER_USER}" "${DOCKER_PASS}" "${TMP_IMAGE}"
done
