#!/bin/bash
docker buildx create --use --name=dockerxbuilder
docker buildx b --platform linux/ppc64le,linux/amd64,linux/s390x,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/386 . --push -t gtary/regioncheck
docker buildx rm dockerxbuilder -f