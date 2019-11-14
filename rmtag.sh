#!/bin/bash

# Do NOT add -x here, or the Docker Hub token will leak
set -e

source config

test "$#" -eq 3
DOCKER_USER="$1"
DOCKER_PASS="$2"
TAG="$3"

# Unfortunately the Docker CLI doesn't expose the ability to delete
# remote tags, so we have to resort to calling the API directly using
# curl
DOCKER_TOKEN=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"username\": \"${DOCKER_USER}\", \"password\": \"${DOCKER_PASS}\"}" https://hub.docker.com/v2/users/login/ | jq -r .token)
curl -X DELETE -H "Authorization: JWT ${DOCKER_TOKEN}" "https://hub.docker.com/v2/repositories/${IMAGE_NAME}/tags/${TAG}/"
