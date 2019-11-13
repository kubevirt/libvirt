#!/bin/bash

set -xe

source config

# A single QEMU binary might emulate multiple architectures, so we
# can't just use the host architecture name but we have to perform
# some processing first
HOST_ARCH=$(uname -m)
case "${HOST_ARCH}" in
    ppc64*) QEMU_ARCH=ppc64 ;;
    *)      QEMU_ARCH="${HOST_ARCH}" ;;
esac

docker build \
    --build-arg FEDORA_VERSION="${FEDORA_VERSION}" \
    --build-arg LIBVIRT_VERSION="${LIBVIRT_VERSION}" \
    --build-arg QEMU_VERSION="${QEMU_VERSION}" \
    --build-arg QEMU_ARCH="${QEMU_ARCH}" \
    -t "${IMAGE_NAME}" .

docker run --rm -it "${IMAGE_NAME}" libvirtd --version
docker run --rm -it "${IMAGE_NAME}" "qemu-system-${QEMU_ARCH}" --version
