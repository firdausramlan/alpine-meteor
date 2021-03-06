#!/bin/sh

set -e

CONTAINER=martinezko/alpine-meteor-example	# <-- Name your container
TAG=latest					# <-- Tag for your container
REGISTRY=false					# <-- If you use other then github repo
BUILD_DIR=`pwd`/.build				# <-- This is where meteor build your files. Folder will be created and after build will be deleted

echo "Start building container ${CONTAINER} ..."

# clean old build if exist
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# install node packages
meteor npm i --production &&

# build meteor app
meteor build --directory $BUILD_DIR --architecture=os.linux.x86_64 --server-only &&

# pull fresh base image:
docker pull martinez/meteor-alpine:latest &&


# build container
docker build --rm -t ${CONTAINER}:${TAG} . &&

# create tag on container
if [ $REGISTRY ]; then
	docker tag ${CONTAINER}:${TAG} ${REGISTRY}/${CONTAINER}:${TAG} &&
else
	docker tag ${CONTAINER}:${TAG} ${CONTAINER}:${TAG} &&
fi

# push to our registry
if [ $REGISTRY ]; then
	docker push ${REGISTRY}/${CONTAINER}:${TAG} &&
else
	docker push ${REGISTRY}/${CONTAINER}:${TAG} &&
fi

# clean images if needed
# docker rmi -f ${CONTAINER}:${TAG} ${REGISTRY}/${CONTAINER}:${TAG} martinez/meteor-alpine:latest

# to run your container
# docker run -d ${REGISTRY}/${CONTAINER}:${TAG}
# OR use docker-compose.yaml file
# docker-compose up -d

# clean build folder
rm -rf .build

echo "End build of container ${CONTAINER} ..."
