#!/bin/sh
docker buildx bake all
# clean up old zlib artifacts
rm -rf linux osx win
# extract zlib artifacts
docker buildx bake artifacts
# consider purging your images