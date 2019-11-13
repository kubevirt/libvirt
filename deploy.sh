#!/bin/bash

set -xe

source config

docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${LIBVIRT_VERSION}"
docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}"
docker push "${IMAGE_NAME}:${LIBVIRT_VERSION}"
