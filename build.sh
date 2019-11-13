#!/bin/bash

set -xe

docker build -t kubevirt/libvirt .
docker run --rm -it kubevirt/libvirt libvirtd --version
