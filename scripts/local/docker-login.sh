#!/bin/bash

set -exu

source scripts/local/setenv.sh

echo "Performing a 'docker login' for DockerHub"
echo "${DOCKERHUB_TOKEN}" | docker login -u "${DOCKERHUB_USERNAME}" docker.io --password-stdin
