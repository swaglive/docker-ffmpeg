FROM        alpine:3.15 as ffmpeg

ARG         version=4.4.1
ARG         MAKEFLAGS="-j4"

RUN         apk add --virtual .build-deps \
                curl \
                build-base \
                nasm \
                yasm \
                pkgconf && \
            curl -sL https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n${version}.tar.gz | tar xz

WORKDIR     FFmpeg-n${version}

RUN         ./configure \
                --disable-debug \
                --disable-programs \
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
            make

###

FROM        alpine:3.15

ENTRYPOINT  ["ffmpeg"]

COPY        --from=ffmpeg /usr/local/bin /usr/local/bin
COPY        --from=ffmpeg /usr/local/include /usr/local/include
