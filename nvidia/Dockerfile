ARG         cuda=11.6.0

###

FROM        nvidia/cuda:${cuda}-devel-ubuntu20.04 as ffnvcodec

ARG         nv_codecs=11.1.5.1
ARG         MAKEFLAGS="-j4"

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

FROM        nvidia/cuda:${cuda}-devel-ubuntu20.04 as ffmpeg

ARG         version=4.4
ARG         MAKEFLAGS="-j4"

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
                libfdk-aac-dev \
                libx264-dev \
                libzmq5-dev \
                libfreetype6-dev \
                libfontconfig1-dev \
                ocl-icd-opencl-dev \
                opencl-headers \
                libvulkan-dev && \
            curl -sL https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n${version}.tar.gz | tar xz

            # Compile and install ffmpeg from source
WORKDIR     FFmpeg-n${version}

COPY        --from=ffnvcodec /usr/local/include/ffnvcodec /usr/local/include/ffnvcodec
COPY        --from=ffnvcodec /usr/local/lib/pkgconfig /usr/local/lib/pkgconfig

#             # HACK: https://trac.ffmpeg.org/ticket/8790
# RUN         sed -i -e 's|nvccflags_default="-gencode arch=compute_30,code=sm_30 -O2"|nvccflags_default="-gencode arch=compute_75,code=sm_75 -O2"|g' configure && \
#             sed -i -e 's|nvccflags_default="--cuda-gpu-arch=sm_30 -O2"|nvccflags_default="--cuda-gpu-arch=sm_75 -O2"|g' configure

RUN 		./configure \
                --prefix=/usr/local \
                --extra-cflags=-I/usr/local/cuda/include \
                --extra-cflags=-I/usr/local/include \
                --extra-ldflags=-L/usr/local/cuda/lib64 \
                --disable-debug \
                --disable-stripping \
                --disable-static \
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
                --enable-libx264 \
                --enable-libfontconfig \
                --enable-libfreetype \
                --enable-cuda-nvcc \
                --enable-vulkan \
                --enable-openssl && \
            make && \
            make install

###

FROM        nvidia/cuda:${cuda}-runtime-ubuntu20.04

ENV         LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
ENV         NVIDIA_DRIVER_CAPABILITIES=compute,video,utility
ENV         DEBIAN_FRONTEND=noninteractive

ENTRYPOINT  ["ffmpeg"]

# RUN         apt-get -y update && \
#             apt-get install -y \
#               libzmq5 \
#               libfdk-aac1 \
#               libx264-155 \
#               ocl-icd-libopencl1 \
#               opencl-headers \
#               libfontconfig1 \
#               libxcb1 \
#               libxcb-shm0 \
#               libxcb-xfixes0 \
#               libxcb-shape0 \
#               libvulkan1 \
#               libssl1.1 && \
#             # FIX: Device creation failed: -19.
#             # REF: https://github.com/microsoft/LightGBM/issues/586
#             mkdir -p /etc/OpenCL/vendors && \
#             echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

COPY        --from=ffmpeg /usr/local/bin /usr/local/bin
COPY        --from=ffmpeg /usr/local/include /usr/local/include
