#!/bin/bash

set -xe

source config

export LIBVIRT_VERSION=$(docker run --rm -it kubevirt/libvirt rpm -q --qf "%{VERSION}-%{RELEASE}\n" libvirt-daemon | tr -d '[:space:]')
docker tag kubevirt/libvirt:latest kubevirt/libvirt:${LIBVIRT_VERSION}
docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}"
docker push kubevirt/libvirt:${LIBVIRT_VERSION}
