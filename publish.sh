#!/bin/bash

docker tag kubevirt/libvirt:4.9.0 docker.io/kubevirt/libvirt:4.9.0
docker push docker.io/kubevirt/libvirt:4.9.0
