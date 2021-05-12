#!/bin/bash

docker build -t betaflight-sitl .
docker run --rm -it --privileged --network=host -v $PWD:/betaflight-sitl-mavlink -t betaflight-sitl