#!/bin/bash

set -xe

source config

docker build \
    -t "${IMAGE_NAME}" .

docker run --rm "${IMAGE_NAME}" libvirtd --version
docker run --rm "${IMAGE_NAME}" "/usr/libexec/qemu-kvm" --version
