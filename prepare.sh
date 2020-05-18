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
