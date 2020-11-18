#!/bin/bash

set -xe

source hack/common.sh

tag="${IMAGE_NAME}:${IMAGE_TAG}"
platform="${DOCKER_PLATFORMS}"

prepare_dockerfile
build_and_test_containers
push_container "${tag}" "${platform}" BUILDER_BUILDX PUSH_REGISTRY
