FROM        ubuntu as ffmpeg

ARG         version=4.4.1
ARG         MAKEFLAGS="-j4"

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt-get update && \
            apt-get install -y \
                curl \
                build-essential \
                nasm \
                yasm \
                pkg-config && \
            curl -sL https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n${version}.tar.gz | tar xz

WORKDIR     FFmpeg-n${version}

RUN         ./configure \
                --disable-debug \
                --disable-doc \
                --disable-ffmpeg \
                --disable-ffplay \
                --disable-encoders \
                --disable-muxers \
                --disable-filters \
                --disable-hwaccels \
                --disable-decoders \
                --disable-indevs \
                --disable-outdevs \
                --enable-small
