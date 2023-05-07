#!/bin/bash

set -exu

source scripts/local/setenv.sh
# Set default GOARCH variable to the host GOARCH, the target architecture can
# be overrided by passing architecture value to the script:
# `GOARCH=<target arch> ./scripts/build-all-in-one-image.sh`.
GOARCH=${GOARCH:-$(go env GOARCH)}

expected_version="v16"
version=$(node --version)
major_version=${version%.*.*}
if [ "$major_version" = "$expected_version" ] ; then
  echo "Node version is as expected: $version"
else
  echo "ERROR: installed Node version $version doesn't match expected version $expected_version"
  exit 1
fi

make build-ui


#make create-baseimg-debugimg

make build-all-in-one GOOS=linux GOARCH=amd64
make build-all-in-one GOOS=linux GOARCH=s390x
make build-all-in-one GOOS=linux GOARCH=ppc64le
make build-all-in-one GOOS=linux GOARCH=arm64
platforms="linux/amd64,linux/s390x,linux/ppc64le,linux/arm64"

#build all-in-one image and upload to dockerhub
bash scripts/local/build-upload-a-docker-image.sh -b -c all-in-one -d cmd/all-in-one -p "${platforms}" -t release