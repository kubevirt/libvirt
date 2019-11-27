#!/bin/bash

set -xe

source config

docker build \
    --build-arg COPR_VERSION="${COPR_VERSION}" \
    --build-arg FEDORA_VERSION="${FEDORA_VERSION}" \
    --build-arg LIBVIRT_VERSION="${LIBVIRT_VERSION}" \
    --build-arg QEMU_VERSION="${QEMU_VERSION}" \
    -t "${IMAGE_NAME}" .

docker run --rm "${IMAGE_NAME}" libvirtd --version
docker run --rm "${IMAGE_NAME}" "/usr/libexec/qemu-kvm" --version
