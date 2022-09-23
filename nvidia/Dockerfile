ARG         cuda=11.7.0
ARG         base=ubuntu22.04

###

FROM        nvidia/cuda:${cuda}-devel-${base} as ffnvcodec

ARG         nv_codecs=10.0.26.2
ARG         MAKEFLAGS="-j8"

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt-get update && \
            apt-get install -y \
              curl \
              make && \
            curl -sfL https://github.com/FFmpeg/nv-codec-headers/archive/n${nv_codecs}.tar.gz | tar xz && \
            cd nv-codec-headers-n${nv_codecs} && \
            make && \
            make install

###

FROM        nvidia/cuda:${cuda}-devel-${base} as ffmpeg

ARG         version=5.1
ARG         MAKEFLAGS="-j8"

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt-get -y update && \
            apt-get install -y \
              curl \
              build-essential \
              nasm \
              yasm \
              pkg-config \
              libssl-dev \
              libpng-dev \
              libass-dev \
              libdrm-dev \
              libdav1d-dev \
              libsvtav1enc-dev \
              libfdk-aac-dev \
              libaom-dev \
              libmp3lame-dev \
              libopus-dev \
              libpulse-dev \
              libsrt-openssl-dev \
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
              libzmq5-dev \
              libxcb1-dev \
              libxcb-shm0-dev \
              libxcb-xfixes0-dev \
              libva-dev \
              libvdpau-dev \
              libvulkan-dev \
              librsvg2-dev \
              libfreetype6-dev \
              libfontconfig1-dev \
              ocl-icd-opencl-dev \
              opencl-headers && \
            curl -sL https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n${version}.tar.gz | tar xz

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
              --enable-libdav1d \
              --enable-libsvtav1 \
              --enable-openssl \
              --enable-libwebp \
              --enable-lto \
              --enable-postproc \
              --enable-pic \
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
              --enable-libdrm \
              --enable-librsvg && \
            make && \
            make install

###

FROM        nvidia/cuda:${cuda}-runtime-${base}

ENV         LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
ENV         NVIDIA_DRIVER_CAPABILITIES=compute,video,utility
ENV         DEBIAN_FRONTEND=noninteractive

ENTRYPOINT  ["ffmpeg"]

RUN         apt-get -y update && \
            apt-get install -y \
              libssl3 \
#               libpng-dev \
              libass9 \
              libdrm2 \
              libdav1d5 \
              libsvtav1enc0 \
              libfdk-aac2 \
              libaom3 \
              libmp3lame0 \
              libopus0 \
              libpulse0 \
              libsrt1.4-openssl \
              libsoxr0 \
              libssh-4 \
              libtheora0 \
              libvidstab1.1 \
#               libvorbis-dev \
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
              ocl-icd-libopencl1 \
              opencl-headers

COPY        --from=ffmpeg /usr/local/bin /usr/local/bin
COPY        --from=ffmpeg /usr/local/include /usr/local/include
COPY        --from=ffmpeg /usr/local/lib /usr/local/lib

#             # FIX: Device creation failed: -19.
#             # REF: https://github.com/microsoft/LightGBM/issues/586
# RUN         mkdir -p /etc/OpenCL/vendors && \
#             echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
