#!/bin/bash
set -x

export LIBVIRT_VERSION=$(docker run --rm -it kubevirt/libvirt libvirtd --version | awk -F' ' '{print $NF}' | tr -d '[:space:]' )
docker tag kubevirt/libvirt:latest kubevirt/libvirt:${LIBVIRT_VERSION}
docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}" && docker push kubevirt/libvirt
