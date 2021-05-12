FROM ubuntu:18.04

# If you want to tinker with this Dockerfile on your machine do as follows:
# - git clone https://github.com/betaflight/docker-betaflight-build.git
# - vim docker-betaflight-build/Dockerfile
# - docker build -t betaflight-build docker-betaflight-build
# - cd <your betaflight source dir>
# - docker run --rm -ti -v `pwd`:/opt/betaflight betaflight-build

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

# Config options you may pass via Docker like so 'docker run -e "<option>=<value>"':
# - TARGET=<name>, specify target platform to build for
#   Specify 'all' to build for all supported platforms. (default: BETAFLIGHTF3)
#   Specify 'test' to build and run the unit tests.
# - OPTIONS=<options> specify build options to be used as defines during the build
#
# What the commands do:

CMD EXTRA_OPTIONS="TARGET=SITL"; \
    if [ -n ${OPTIONS} ]; then \
        EXTRA_OPTIONS="OPTIONS=${OPTIONS}"; \
        unset OPTIONS; \
    fi; \
    CLEAN_TARGET=clean; \
    BUILD_TARGET=; \
    if [ ${TARGET} = 'test' ]; then \
        CLEAN_TARGET=test_clean; \
        BUILD_TARGET=test; \
    elif [ ${TARGET} = 'all' ]; then \
        CLEAN_TARGET=clean_all; \
        BUILD_TARGET=all; \
    elif [ ${TARGET} = 'unified' ]; then \
        CLEAN_TARGET=clean_all; \
        BUILD_TARGET=unified; \
    elif [ ${TARGET} = 'unified_zip' ]; then \
        CLEAN_TARGET=clean_all; \
        BUILD_TARGET=unified_zip; \
    elif [ ${TARGET} = 'pre-push' ]; then \
        CLEAN_TARGET=clean; \
        BUIILD_TARGET=pre-push; \
    else \
        CLEAN_TARGET="clean TARGET=${TARGET}"; \
        BUILD_TARGET="TARGET=${TARGET}"; \
    fi; \
    unset TARGET; \
    make ARM_SDK_DIR=${ARM_SDK_DIR} ${CLEAN_TARGET}; \
    make ARM_SDK_DIR=${ARM_SDK_DIR} ${BUILD_TARGET} ${EXTRA_OPTIONS}
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