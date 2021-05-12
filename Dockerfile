FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update &&\
    apt-get -y install \
        build-essential \
        gdb \
        software-properties-common \
        git \
        ccache \
        python3-dev \
        python3-pip \
        curl \
        bzip2 \
        libblocksruntime-dev

RUN add-apt-repository -y ppa:team-gcc-arm-embedded/ppa &&\
    apt-get -y update &&\
    apt-get -y install gcc-arm-embedded

ENV ARM_SDK_DIR="/usr/"

ENV PATH="${workspaceFolder}/betaflight/obj/main:$PATH"

# Install dependencies, MAVProxy and add to PATH
RUN apt-get update &&\
    apt-get install -y \
        python3-dev \
        python3-opencv \
        python3-wxgtk4.0 \
        python3-pip \
        python3-matplotlib \
        python3-lxml
RUN pip3 install PyYAML pygame mavproxy
RUN export PATH=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib'))")/MAVProxy:${PATH}

# Install pymavlink
# Disable mavnative to enable support for MAVLink v1+
# https://github.com/ArduPilot/pymavlink/#mavnative
RUN apt-get install -y \
    python3-numpy python3-pytest    
ENV DISABLE_MAVNATIVE=True
RUN pip3 install pymavlink

CMD cd /betaflight-sitl-mavlink/betaflight && make TARGET=SITL && obj/main/betaflight_SITL.elf