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

# Install the betaflight configurator
ARG BETAFLIGHT_CONFIGURATION_URL="https://github.com/betaflight/betaflight-configurator/releases/download/10.7.0/betaflight-configurator_10.7.0_amd64.deb"
# Install tools and required packages
RUN apt-get update &&\
    apt-get install -y \
        wget \
        libgconf-2-4 \
        xdg-utils \
        libasound2 \
        mesa-utils

# nvidia docker runtime env
ENV NVIDIA_VISIBLE_DEVICES \
        ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
        ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,compat32,utility

RUN wget -O /tmp/betaflight_configuration.deb $BETAFLIGHT_CONFIGURATION_URL &&\
    mkdir /usr/share/desktop-directories &&\
    dpkg -i /tmp/betaflight_configuration.deb &&\
    ln -sfn /opt/betaflight/betaflight-configurator/betaflight-configurator /usr/local/bin/betaflight-configurator