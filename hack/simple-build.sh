#!/bin/bash

set -xe

source hack/common.sh

# FIXME: change this so that it works on non-x86
tag="${IMAGE_NAME}:${IMAGE_TAG}"
platform="linux/amd64"

prepare_dockerfile
build_container "${tag}" "${platform}" BUILDER_BUILD PUSH_DOCKER
push_container "${tag}" "${platform}" BUILDER_BUILD PUSH_DOCKER
test_container "${tag}" "${platform}" BUILDER_BUILD PUSH_DOCKER
