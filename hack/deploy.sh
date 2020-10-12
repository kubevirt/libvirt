#!/bin/bash

set -xe

source hack/config
source hack/common.sh

docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}"
docker push "${IMAGE_NAME}:${TAG}"
