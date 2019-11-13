#!/bin/bash

set -xe

source config

export LIBVIRT_VERSION=$(docker run --rm -it "${IMAGE_NAME}" rpm -q --qf "%{VERSION}-%{RELEASE}\n" libvirt-daemon | tr -d '[:space:]')
docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${LIBVIRT_VERSION}"
docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}"
docker push "${IMAGE_NAME}:${LIBVIRT_VERSION}"
