#!/bin/bash

# check if there are 2 arguments
if [ "$#" -eq 2 ]; then
  p="$2"
else
  p="$HOME/Downloads"
fi

docker run \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v $p:/output \
  --privileged -t --rm \
  singularityware/docker2singularity $1
