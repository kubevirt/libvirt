#!/bin/bash

docker tag kubevirt/libvirt:5.4.0 docker.io/kubevirt/libvirt:5.4.0
docker push docker.io/kubevirt/libvirt:5.4.0
