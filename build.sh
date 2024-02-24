#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPT_PATH=`dirname $SCRIPT`
BASE_PATH=`dirname $SCRIPT_PATH`

RETVAL=0
VERSION=3.14
SUBVERSION=5
IMAGE_NAME="alpine"
TAG=`date '+%Y%m%d_%H%M%S'`

echo "Image bayrell/$IMAGE_NAME build script"

case "$1" in
	
	test)
		docker build ./ -t bayrell/$IMAGE_NAME:$VERSION-$SUBVERSION-$TAG --file Dockerfile
	;;
	
	amd64)
		docker build ./ -t bayrell/$IMAGE_NAME:$VERSION-$SUBVERSION-amd64 \
			--file Dockerfile --build-arg ARCH=amd64/
	;;
	
	arm32v7)
		docker build ./ -t bayrell/$IMAGE_NAME:$VERSION-$SUBVERSION-arm32v7 \
			--file Dockerfile --build-arg ARCH=arm32v7/
	;;
	
	arm64v8)
		docker build ./ -t bayrell/$IMAGE_NAME:$VERSION-$SUBVERSION-arm64v8 \
			--file Dockerfile --build-arg ARCH=arm64v8/
	;;
	
	manifest)
		rm -rf ~/.docker/manifests/docker.io_bayrell_alpine-*
		
		docker tag bayrell/alpine:$VERSION-$SUBVERSION-amd64 bayrell/alpine:$VERSION-amd64
		docker tag bayrell/alpine:$VERSION-$SUBVERSION-arm32v7 bayrell/alpine:$VERSION-arm32v7
		docker tag bayrell/alpine:$VERSION-$SUBVERSION-arm64v8 bayrell/alpine:$VERSION-arm64v8
		
		docker push bayrell/alpine:$VERSION-$SUBVERSION-amd64
		docker push bayrell/alpine:$VERSION-$SUBVERSION-arm32v7
		docker push bayrell/alpine:$VERSION-$SUBVERSION-arm64v8
		
		docker push bayrell/alpine:$VERSION-amd64
		docker push bayrell/alpine:$VERSION-arm32v7
		docker push bayrell/alpine:$VERSION-arm64v8
		
		docker manifest create bayrell/alpine:$VERSION-$SUBVERSION \
			--amend bayrell/alpine:$VERSION-$SUBVERSION-amd64 \
			--amend bayrell/alpine:$VERSION-$SUBVERSION-arm32v7 \
			--amend bayrell/alpine:$VERSION-$SUBVERSION-arm64v8
		docker manifest push bayrell/alpine:$VERSION-$SUBVERSION
		
		docker manifest create bayrell/alpine:$VERSION \
			--amend bayrell/alpine:$VERSION-amd64 \
			--amend bayrell/alpine:$VERSION-arm32v7 \
			--amend bayrell/alpine:$VERSION-arm64v8
		docker manifest push bayrell/alpine:$VERSION
	;;
	
	upload-github)
		docker tag bayrell/alpine:$VERSION-arm64v8 \
		    ghcr.io/bayrell-os/alpine:$VERSION-arm64v8
		
		docker tag bayrell/alpine:$VERSION-amd64 \
		    ghcr.io/bayrell-os/alpine:$VERSION-amd64
		
		docker push ghcr.io/bayrell-os/alpine:$VERSION-amd64
		docker push ghcr.io/bayrell-os/alpine:$VERSION-arm64v8
		
		docker manifest create --amend \
		    ghcr.io/bayrell-os/alpine:$VERSION \
			ghcr.io/bayrell-os/alpine:$VERSION-amd64 \
			ghcr.io/bayrell-os/alpine:$VERSION-arm64v8
		docker manifest push --purge ghcr.io/bayrell-os/alpine:$VERSION
	;;
	
	all)
		$0 amd64
		$0 arm64v8
		$0 arm32v7
		$0 manifest
	;;
	
	*)
		echo "Usage: $0 {amd64|arm64v8|arm32v7|manifest|all|test}"
		RETVAL=1

esac

exit $RETVAL

