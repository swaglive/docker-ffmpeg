ARG         cuda=
ARG         base=ubuntu22.04

###

FROM        nvidia/cuda:${cuda}-devel-${base} as base

ARG         MAKEFLAGS=

ENV         MAKEFLAGS=${MAKEFLAGS}
ENV         DEBIAN_FRONTEND=noninteractive

RUN         echo ${MAKEFLAGS} && \
            apt-get update && \
            apt-get install -y \
              wget \
              make

###

FROM        base as ffnvcodec

ARG         nv_codecs=

RUN         wget -q -O - https://github.com/FFmpeg/nv-codec-headers/archive/n${nv_codecs}.tar.gz | tar xz && \
            cd nv-codec-headers-n${nv_codecs} && \
            make && \
            make install

###

FROM        base as ffmpeg

ARG         repo=FFmpeg/FFmpeg
ARG         version=
ARG         ffmpeg_flags=

            # ffmpeg requires vulkan>=1.2.189
            # REF: https://github.com/FFmpeg/FFmpeg/blob/57afccc0ef8d3024ffb2d1b2d25c9670b9501248/configure#L7015
RUN         wget -q -O - http://packages.lunarg.com/lunarg-signing-key-pub.asc | apt-key add - && \
            wget -q -O /etc/apt/sources.list.d/lunarg-vulkan-focal.list http://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list && \
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
              vulkan-headers \
              vulkan-profiles \
              vulkan-tools \
              vulkan-sdk \
              librsvg2-dev \
              libfreetype6-dev \
              libfontconfig1-dev \
              libnuma-dev \
              ocl-icd-opencl-dev \
              opencl-headers \
              glslang-dev && \
            wget -q -O - https://github.com/${repo}/archive/refs/tags/n${version}.tar.gz | tar xz

WORKDIR 	  FFmpeg-n${version}

COPY        --from=ffnvcodec /usr/local/include/ffnvcodec /usr/local/include/ffnvcodec
COPY        --from=ffnvcodec /usr/local/lib/pkgconfig /usr/local/lib/pkgconfig

#             # HACK: https://trac.ffmpeg.org/ticket/8790
# RUN         sed -i -e 's|nvccflags_default="-gencode arch=compute_30,code=sm_30 -O2"|nvccflags_default="-gencode arch=compute_75,code=sm_75 -O2"|g' configure && \
#             sed -i -e 's|nvccflags_default="--cuda-gpu-arch=sm_30 -O2"|nvccflags_default="--cuda-gpu-arch=sm_75 -O2"|g' configure

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
              --enable-libglslang \
              ${ffmpeg_flags} && \
            make && \
            make install

###

FROM        nvidia/cuda:${cuda}-runtime-${base} as nvidia-drivers

ARG         version_nvidia_driver=

RUN         apt-get update && \
            apt-get install -y \
              wget \
              kmod && \
            wget -q -O nvidia.run https://us.download.nvidia.com/tesla/${version_nvidia_driver}/NVIDIA-Linux-$(uname -m)-${version_nvidia_driver}.run && \
            sh "nvidia.run" \
              --no-install-compat32-libs \
              --no-drm \
              --silent \
              --accept-license \
              --no-kernel-modules \
              --utility-prefix /usr/local \
              --opengl-prefix /usr/local

###

FROM        nvidia/cuda:${cuda}-runtime-${base}

ENV         LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
ENV         NVIDIA_DRIVER_CAPABILITIES=compute,video,utility
ENV         DEBIAN_FRONTEND=noninteractive

ENTRYPOINT  ["ffmpeg"]

RUN         apt-get -y update && \
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
              ocl-icd-libopencl1 \
              opencl-headers \
              vulkan-tools \
              glslang-tools

COPY        --from=nvidia-drivers /usr/local/bin/ /usr/local/bin/
COPY        --from=nvidia-drivers /usr/local/include/ /usr/local/include/
COPY        --from=nvidia-drivers /usr/local/lib/ /usr/local/lib/

COPY        --from=nvidia-drivers /etc/OpenCL/vendors/nvidia.icd /etc/OpenCL/vendors/nvidia.icd
COPY        --from=nvidia-drivers /etc/vulkan/ /etc/vulkan/
COPY        --from=nvidia-drivers /etc/vulkan/icd.d/ /usr/share/vulkan/icd.d/
COPY        --from=nvidia-drivers /etc/vulkan/implicit_layer.d/ /usr/share/vulkan/implicit_layer.d/
COPY        --from=nvidia-drivers /usr/share/glvnd/ /usr/share/glvnd/
COPY        --from=nvidia-drivers /usr/share/egl/ /usr/share/egl/

COPY        --from=ffmpeg /usr/local/bin/ /usr/local/bin/
COPY        --from=ffmpeg /usr/local/include/ /usr/local/include/
COPY        --from=ffmpeg /usr/local/lib/ /usr/local/lib/
