#!/bin/bash

docker tag kubevirt/libvirt:5.0.0 docker.io/kubevirt/libvirt:5.0.0
docker push docker.io/kubevirt/libvirt:5.0.0
