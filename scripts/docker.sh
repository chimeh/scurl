#!/bin/bash
THIS_SCRIPT=$(realpath $(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)/$(basename ${BASH_SOURCE:-$0}))
#automatic detection TOPDIR
SCRIPT_DIR=$(dirname $(realpath ${THIS_SCRIPT}))

USAGE="
  usage:
  docker build script:
  I. build docker:
  $(basename $(realpath $0)) [/path/to/your-dockerfile]
  II. build docker then push:
  export DOCKER_REPO=
  export DOCKER_NS=
  export DOCKER_USER=
  export DOCKER_PASS=
  $(basename $(realpath $0)) [/path/to/your-dockerfile]
"

if [[ $# -lt 1 ]];then
    if [[ -f ${PWD}/Dockerfile ]];then
      DOCKERFILE=${PWD}/Dockerfile
    else
      echo "${USAGE}"
      exit 1
    fi
else
    GIVE_DOCKERFILE=$1
    if [[ -f ${GIVE_DOCKERFILE} ]];then
      DOCKERFILE=$(realpath ${GIVE_DOCKERFILE} )
    else
      echo "error, Dockerfile not found"
      echo "${USAGE}"
      exit 1
    fi
fi

docker build . --file ${DOCKERFILE} --tag imagex

DOCKER_REPO=${DOCKER_REPO:-registry-1.docker.io}
DOCKER_NS=${DOCKER_NS:-bettercode}
DOCKER_USER=${DOCKER_USER:-bettercode}
DOCKER_PASS=${DOCKER_PASS}

if [[ -n ${DOCKER_PASS} ]];then
  docker login -u "${DOCKER_USER}" -p  "${DOCKER_PASS}" ${DOCKER_REPO}/${DOCKER_NS}
  IMAGE_URL=${DOCKER_REPO}/${DOCKER_NS}/$(basename ${PWD})
  # Change all uppercase to lowercase
  IMAGE_URL=$(echo $IMAGE_URL | tr '[A-Z]' '[a-z]')

  # Strip git ref prefix from version
  SRC_VERSION=$(echo "$(git describe  --tags --always|head -n 1)" | sed -e 's,.*/\(.*\),\1,')
  TAG=${SRC_VERSION}


  echo IMAGE_URL=$IMAGE_URL
  echo SRC_VERSION=$SRC_VERSION
  echo TAG=$TAG

  docker tag imagex $IMAGE_URL:${TAG}
  docker tag imagex $IMAGE_URL:latest
  docker push $IMAGE_URL:${TAG}
  docker push $IMAGE_URL:latest
  docker rmi imagex
  docker rmi $IMAGE_URL:${TAG}
  docker rmi $IMAGE_URL:latest
fi