#!/bin/bash

set -xe

source config

GIT_UNIX_TIMESTAMP=$(git show --format='%ct' | head -1)
GIT_TIMESTAMP=$(date --date="@${GIT_UNIX_TIMESTAMP}" '+%Y%m%d')
GIT_COMMIT=$(git describe --always)
HOST_ARCH=$(uname -m)
TAG="${GIT_TIMESTAMP}.${GIT_COMMIT}"

docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}"

docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${TAG}.${HOST_ARCH}"
docker push "${IMAGE_NAME}:${TAG}.${HOST_ARCH}"
