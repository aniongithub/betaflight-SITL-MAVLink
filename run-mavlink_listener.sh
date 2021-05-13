#!/bin/bash

docker build -t betaflight-sitl .
docker run --rm -it --privileged --network=host -v $PWD:/betaflight-sitl-mavlink -t betaflight-sitl python3 "/betaflight-sitl-mavlink/mavlink_listener.py" --device udp:127.0.0.1:5761