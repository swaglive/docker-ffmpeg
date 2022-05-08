FROM        ubuntu as ffmpeg

ARG         version=4.4.1
ARG         MAKEFLAGS="-j4"

RUN         apt-get update && \
            apt-get install -y \
                curl \
                build-essential \
                nasm \
                yasm \
                pkg-config \
                libssl-dev && \
            curl -sL https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n${version}.tar.gz | tar xz

WORKDIR     FFmpeg-n${version}

RUN         ./configure \
                --disable-debug \
                --disable-doc \
                --disable-htmlpages \
                --disable-manpages \
                --disable-podpages \
                --disable-txtpages \
                --disable-ffmpeg \
                --disable-ffplay \
                --disable-encoders \
                --disable-muxers \
                --disable-filters \
                --disable-hwaccels \
                --disable-decoders \
                --disable-indevs \
                --disable-outdevs \
                --enable-small && \
            make && \
            make install

###

FROM        ubuntu

ENTRYPOINT  ["ffmpeg"]

COPY        --from=ffmpeg /usr/local/bin /usr/local/bin
COPY        --from=ffmpeg /usr/local/include /usr/local/include
