#!/bin/bash

set -xe

source config

# Install the latest version of Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get -y -o Dpkg::Options::="--force-confnew" install docker-ce

# Enable experimental features for the Docker client
mkdir -p ~/.docker
cp docker-client.json ~/.docker/config.json

# Enable experimental features for the Docker daemon
sudo cp docker-daemon.json /etc/docker/daemon.json
sudo systemctl restart docker

# Install the buildx Docker plugin
DOCKER_BUILDKIT=1 docker build --platform=local -o . git://github.com/docker/buildx
mkdir -p ~/.docker/cli-plugins
mv buildx ~/.docker/cli-plugins/docker-buildx

# Set up the cross-architecture build environment
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --use
docker buildx inspect --bootstrap

# Prepare Dockerfile
#
# We need to do this instead of using the ARG feature because buildx
# doesn't currently behave correctly when cross-building containers
# that use that feature: preprocessing the file ourselves works
# around that limitation
sed -e "s/@FEDORA_VERSION@/${FEDORA_VERSION}/g" \
    -e "s/@COPR_VERSION@/${COPR_VERSION}/g" \
    -e "s/@LIBVIRT_VERSION@/${LIBVIRT_VERSION}/g" \
    -e "s/@QEMU_VERSION@/${QEMU_VERSION}/g" \
    <Dockerfile.in >Dockerfile
