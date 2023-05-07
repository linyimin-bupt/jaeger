#!/bin/bash

set -exu

base_img_arg=""
docker_file_arg="Dockerfile"
target_arg=""
platforms="linux/amd64"

while getopts "bc:d:f:p:t:" opt; do
	# shellcheck disable=SC2220 # we don't need a *) case
	case "${opt}" in
	c)
		component_name=${OPTARG}
		;;
	b)
		base_img_arg="--build-arg base_image=localhost:5001/baseimg_alpine:latest"
		;;
	d)
		dir_arg=${OPTARG}
		;;
	f)
		docker_file_arg=${OPTARG}
		;;
	p)
		platforms=${OPTARG}
		;;
	t)
		target_arg=${OPTARG}
		;;
	esac
done

if [ -n "${target_arg}" ]; then
    target_arg="--target ${target_arg}"
fi

docker_file_arg="${dir_arg}/${docker_file_arg}"

IMAGE_TAGS="--tag docker.io/${DOCKERHUB_NAME_SPACE}/${component_name}:${TAG} --tag docker.io/${DOCKERHUB_NAME_SPACE}/${component_name}:latest"
upload_flag=""

# Only push multi-arch images to dockerhub for main branch or for release tags vM.N.P
if [[ "$BRANCH" == "main" || $BRANCH =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "build docker images and upload to dockerhub, BRANCH=$BRANCH"
  bash scripts/local/docker-login.sh
  PUSHTAG="type=image, push=true"
  upload_flag=" and uploading"
else
  echo 'skip docker images upload, only allowed for tagged releases or main (latest tag)'
  PUSHTAG="type=image, push=false"
fi

docker buildx build --output "${PUSHTAG}" \
	--progress=plain ${target_arg} ${base_img_arg}\
	--platform=${platforms} \
	--file ${docker_file_arg} \
	${IMAGE_TAGS} \
	${dir_arg}

echo "Finished building${upload_flag} ${component_name} =============="
