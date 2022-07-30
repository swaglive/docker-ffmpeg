ARG         base=alpine:3.16

###

FROM        ${base} as ffmpeg

ARG         version=5.1
ARG         MAKEFLAGS="-j8"

RUN         apk add --virtual .build-deps \
                curl \
                build-base \
                nasm \
                yasm \
                pkgconf \
                openssl-dev \
                libpng-dev \
                libass-dev \
                libdrm-dev \
                dav1d-dev \
                fdk-aac-dev \
                aom-dev \
                lame-dev \
                opus-dev \
                pulseaudio-dev \
                libsrt-dev \
                soxr-dev \
                libssh-dev \
                libtheora-dev \
                v4l-utils-dev \
                vidstab-dev \
                libvorbis-dev \
                libvpx-dev \
                libwebp-dev \
                x264-dev \
                x265-dev \
                xvidcore-dev \
                zeromq-dev \
                libxcb-dev \
                libva-dev \
                libvdpau-dev \
                vulkan-loader-dev \
                && \
            curl -sL https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n${version}.tar.gz | tar xz

WORKDIR     FFmpeg-n${version}

RUN         ./configure \
                --disable-debug \
                --disable-stripping \
                --disable-ffplay \
                --disable-static \
                --disable-librtmp \
                --enable-small \
                --enable-shared \
                --enable-nonfree \
                --enable-gpl \
                --enable-swresample \
                --enable-avfilter \
                --enable-fontconfig \
                --enable-libzmq \
                --enable-libfdk_aac \
                --enable-libfontconfig \
                --enable-libfreetype \
                --enable-libass \
                --enable-libmp3lame \
                --enable-libpulse \
                --enable-libvorbis \
                --enable-libvpx \
                --enable-libxvid \
                --enable-libx264 \
                --enable-libx265 \
                --enable-libtheora \
                --enable-libv4l2 \
                --enable-libdav1d \
                --enable-openssl \
                --enable-libwebp \
                --enable-lto \
                --enable-postproc \
                --enable-pic \
                --enable-pthreads \
                --enable-shared \
                --enable-libxcb \
                --enable-libsrt \
                --enable-libssh \
                --enable-libvidstab \
                --enable-libaom \
                --enable-libopus \
                --enable-libsoxr \
                --enable-vaapi \
                --enable-vdpau \
                --enable-vulkan \
                --enable-libdrm && \
            make && \
            make install

###

FROM        ${base}

ENTRYPOINT  ["ffmpeg"]

RUN         apk add --virtual .run-deps \
                openssl \
                libpng \
                libass \
                libdrm \
                dav1d \
                fdk-aac \
                aom \
                lame \
                opus \
                pulseaudio \
                libsrt \
                soxr \
                libssh \
                libtheora \
                v4l-utils \
                vidstab \
                libvorbis \
                libvpx \
                libwebp \
                x264 \
                x265 \
                xvidcore \
                zeromq \
                libxcb \
                libva \
                libvdpau \
                vulkan-loader

COPY        --from=ffmpeg /usr/local/bin /usr/local/bin
COPY        --from=ffmpeg /usr/local/include /usr/local/include