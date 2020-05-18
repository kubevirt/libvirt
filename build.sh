#!/bin/bash

set -xe

source config

# We need to build for one architecture at a time because buildx
# can't currently export multi-architecture containers to the Docker
# daemon, so we wouldn't be able to test the results otherwise. The
# deploy step will reuse the cached layers, so we're not wasting any
# extra time building twice nor are we uploading contents that we
# haven't made sure actually works
for ARCH in ${TARGET_ARCHITECTURES}; do

    TAG="${ARCH}"
    DOCKER_PLATFORM="linux/${ARCH}"

    docker buildx build \
        --load \
        --platform="${DOCKER_PLATFORM}" \
        --tag "${IMAGE_NAME}:${TAG}" \
        .

    docker run \
        --rm \
        --platform="${DOCKER_PLATFORM}" \
        "${IMAGE_NAME}:${TAG}" \
        uname -m
    docker run \
        --rm \
        --platform="${DOCKER_PLATFORM}" \
        "${IMAGE_NAME}:${TAG}" \
        libvirtd --version
    docker run \
        --rm \
        --platform="${DOCKER_PLATFORM}" \
        "${IMAGE_NAME}:${TAG}" \
        /usr/libexec/qemu-kvm --version

    docker rmi "${IMAGE_NAME}:${TAG}"
done
