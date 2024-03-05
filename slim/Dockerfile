ARG         ubuntu_base=22.04

###

FROM        ubuntu:${ubuntu_base} as base

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt-get update && \
            apt-get install -y \
              libssl3

###

FROM        base as build-base

ARG         makeflags=

ENV         MAKEFLAGS=${makeflags}

RUN         apt-get install -y \
              wget \
              make

###

FROM        build-base as ffmpeg

ARG         repo=FFmpeg/FFmpeg
ARG         version=

RUN         apt-get -y update && \
            apt-get install -y \
              build-essential \
              nasm \
              yasm \
              pkg-config \
              libssl-dev \
              libpng-dev && \
            wget -q -O - https://github.com/${repo}/archive/refs/tags/n${version}.tar.gz | tar xz

WORKDIR     FFmpeg-n${version}

RUN         ./configure \
                --disable-debug \
                --disable-doc \
                --disable-htmlpages \
                --disable-manpages \
                --disable-podpages \
                --disable-txtpages \
                --disable-ffplay \
                --disable-encoders \
                --disable-muxers \
                --disable-filters \
                --disable-hwaccels \
                --disable-indevs \
                --disable-outdevs \
                --enable-small \
                --enable-openssl && \
            make && \
            make install

###

FROM        base

ENTRYPOINT  ["ffmpeg"]

COPY        --from=ffmpeg /usr/local/bin /usr/local/bin
COPY        --from=ffmpeg /usr/local/include /usr/local/include
