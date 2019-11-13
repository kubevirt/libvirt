#!/bin/bash

set -x

docker build -t kubevirt/libvirt .
docker run --rm -it kubevirt/libvirt libvirtd --version
