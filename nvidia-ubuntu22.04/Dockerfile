ARG         cuda=
ARG         ubuntu_base=22.04

###

FROM        nvidia/cuda:${cuda}-devel-ubuntu${ubuntu_base} as build-base

ARG         makeflags=

ENV         MAKEFLAGS=${makeflags}
ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt-get update && \
            apt-get install -y \
              wget \
              make

###

FROM        build-base as ffnvcodec

ARG         nvidia_video_codec_sdk=

RUN         wget -q -O - https://github.com/FFmpeg/nv-codec-headers/archive/n${nvidia_video_codec_sdk}.tar.gz | tar xz && \
            cd nv-codec-headers-n${nvidia_video_codec_sdk} && \
            make && \
            make install

###

FROM        build-base as ffmpeg

ARG         repo=FFmpeg/FFmpeg
ARG         version=

            # ffmpeg 6.1 requires vulkan>=1.3.255
            # REF: https://github.com/FFmpeg/FFmpeg/blob/n6.1/configure#L7151
RUN         wget -q -O - http://packages.lunarg.com/lunarg-signing-key-pub.asc | apt-key add - && \
            wget -q -P /etc/apt/sources.list.d/ http://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list && \
            apt-get -y update && \
            apt-get install -y \
              wget \
              build-essential \
              nasm \
              yasm \
              pkg-config \
              libssl-dev \
              libpng-dev \
              libass-dev \
              libdrm-dev \
              libfdk-aac-dev \
              libaom-dev \
              libmp3lame-dev \
              libopus-dev \
              libpulse-dev \
              libsoxr-dev \
              libssh-dev \
              libtheora-dev \
              libvidstab-dev \
              libvorbis-dev \
              libvpx-dev \
              libwebp-dev \
              libx264-dev \
              libx265-dev \
              libxvidcore-dev \
              libzmq3-dev \
              libxcb1-dev \
              libxcb-shm0-dev \
              libxcb-xfixes0-dev \
              libva-dev \
              libvdpau-dev \
              libvulkan-dev \
              vulkan-headers \
              vulkan-tools \
              spirv-tools \
              librsvg2-dev \
              libfreetype6-dev \
              libfontconfig1-dev \
              libnuma-dev \
              ocl-icd-opencl-dev \
              opencl-headers \
              libxml2-dev \
              shaderc && \
            wget -q -O - https://github.com/${repo}/archive/refs/tags/n${version}.tar.gz | tar xz

WORKDIR 	  FFmpeg-n${version}

COPY        --from=ffnvcodec /usr/local/include/ffnvcodec /usr/local/include/ffnvcodec
COPY        --from=ffnvcodec /usr/local/lib/pkgconfig /usr/local/lib/pkgconfig

RUN 		    ./configure \
              --prefix=/usr/local \
              --extra-cflags=-I/usr/local/include \
              --extra-cflags=-I/usr/local/cuda/include \
              --extra-ldflags=-L/usr/local/lib \
              --extra-ldflags=-L/usr/local/cuda/lib64 \
              --disable-debug \
              --disable-doc \
              --disable-htmlpages \
              --disable-manpages \
              --disable-podpages \
              --disable-txtpages \
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
              --enable-nvenc \
              --enable-cuda \
              --enable-cuvid \
              --enable-libnpp \
              --enable-opencl \
              --enable-libfdk_aac \
              --enable-pthreads \
              --enable-libfontconfig \
              --enable-libfreetype \
              --enable-cuda-nvcc \
              --enable-libass \
              --enable-libmp3lame \
              --enable-libpulse \
              --enable-libvorbis \
              --enable-libvpx \
              --enable-libxvid \
              --enable-libx264 \
              --enable-libx265 \
              --enable-libtheora \
              --enable-openssl \
              --enable-libwebp \
              --enable-lto \
              --enable-postproc \
              --enable-pic \
              --enable-libxcb \
              --enable-libssh \
              --enable-libvidstab \
              --enable-libaom \
              --enable-libopus \
              --enable-libsoxr \
              --enable-vaapi \
              --enable-vdpau \
              --enable-libdrm \
              --enable-librsvg \
              --enable-vulkan \
              --enable-libshaderc \
              --enable-libxml2 && \
            make && \
            make install

###

FROM        nvidia/cuda:${cuda}-runtime-ubuntu${ubuntu_base}

ENV         LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
ENV         NVIDIA_DRIVER_CAPABILITIES=compute,video,utility
ENV         DEBIAN_FRONTEND=noninteractive

ENTRYPOINT  ["ffmpeg"]

            # ffmpeg 6.1 requires vulkan>=1.3.255
            # REF: https://github.com/FFmpeg/FFmpeg/blob/n6.1/configure#L7151
RUN         apt-get -y update && \
            apt-get install -y \
              wget && \
            wget -q -O - http://packages.lunarg.com/lunarg-signing-key-pub.asc | apt-key add - && \
            wget -q -P /etc/apt/sources.list.d/ http://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list && \
            apt-get -y update && \
            apt-get install -y \
              libssl3 \
              libass9 \
              libdrm2 \
              libfdk-aac2 \
              libaom3 \
              libmp3lame0 \
              libopus0 \
              libpulse0 \
              libsoxr0 \
              libssh-4 \
              libtheora0 \
              libvidstab1.1 \
              libvpx7 \
              libwebpmux3 \
              libx264-163 \
              libx265-199 \
              libxvidcore4 \
              libzmq5 \
              libxcb1 \
              libxcb-shm0 \
              libxcb-xfixes0 \
              libxcb-shape0 \
              libva2 \
              libva-drm2 \
              libva-x11-2 \
              libvdpau1 \
              libvulkan1 \
              librsvg2-2 \
              libnuma1 \
              libxml2 \
              ocl-icd-libopencl1 \
              opencl-headers \
              vulkan-tools \
              spirv-tools \
              shaderc && \
            apt-get clean autoclean && \
            apt-get autoremove -y && \
            rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY        --from=ffmpeg /usr/local/bin/ /usr/local/bin/
COPY        --from=ffmpeg /usr/local/include/ /usr/local/include/
COPY        --from=ffmpeg /usr/local/lib/ /usr/local/lib/
