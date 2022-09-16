FROM        nvidia/cuda:10.2-devel as ffnvcodec

ARG         NV_CODECS_HEADERS_VERSION=n9.1.23.2
ARG         MAKEFLAGS=-j$(nproc)
ENV         DEBIAN_FRONTEND=noninteractive

            # Nvidia did the key rotation to CUDA linux Repository on 2022/04
            # https://forums.developer.nvidia.com/t/notice-cuda-linux-repository-key-rotation
RUN         apt-key del 7fa2af80 && \
            apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub && \
            apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN         apt-get update && \
            apt-get install -y \
                curl \
                make

RUN         curl -sfL https://github.com/FFmpeg/nv-codec-headers/archive/$NV_CODECS_HEADERS_VERSION.tar.gz | tar xz
WORKDIR 	nv-codec-headers-$NV_CODECS_HEADERS_VERSION

RUN         make && \
            make install

###

FROM        nvidia/cuda:10.2-devel as ffmpeg

ARG         FFMPEG_VERSION=n5.0
ARG         MAKEFLAGS=-j$(nproc)
ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt-key del 7fa2af80 && \
            apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub && \
            apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN         apt-get -y update && \
            apt-get install -y \
                curl

            # Compile and install ffmpeg from source
RUN 	  	curl -sfL https://github.com/FFmpeg/FFmpeg/archive/$FFMPEG_VERSION.tar.gz | tar xz
WORKDIR 	FFmpeg-$FFMPEG_VERSION

RUN         apt-get -y update && \
            apt-get install -y \
                build-essential \
                yasm \
                pkg-config \
                libfdk-aac-dev \
                libx264-dev \
                libzmq5-dev \
                libfreetype6-dev \
                libfontconfig1-dev \
                ocl-icd-opencl-dev \
                opencl-headers \
                libssl-dev

COPY        --from=ffnvcodec /usr/local/include/ffnvcodec /usr/local/include/ffnvcodec
COPY        --from=ffnvcodec /usr/local/lib/pkgconfig /usr/local/lib/pkgconfig

            # HACK: https://trac.ffmpeg.org/ticket/8790
RUN         sed -i -e 's|nvccflags_default="-gencode arch=compute_30,code=sm_30 -O2"|nvccflags_default="-gencode arch=compute_75,code=sm_75 -O2"|g' configure && \
            sed -i -e 's|nvccflags_default="--cuda-gpu-arch=sm_30 -O2"|nvccflags_default="--cuda-gpu-arch=sm_75 -O2"|g' configure

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
                --enable-openssl

RUN         make && \
            make install

###

FROM        nvidia/cuda:10.2-runtime

ENV         LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
ENV         NVIDIA_DRIVER_CAPABILITIES=compute,video,utility
ENV         DEBIAN_FRONTEND=noninteractive

ENTRYPOINT  ["ffmpeg"]

RUN         apt-key del 7fa2af80 && \
            apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub && \
            apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN         apt-get -y update && \
            apt-get install -y \
                libzmq5 \
                libfdk-aac1 \
                libx264-152 \
                ocl-icd-libopencl1 \
                opencl-headers \
                libfontconfig1 \
                libxcb1 \
                libxcb-shm0 \
                libxcb-xfixes0 \
                libxcb-shape0 \
                libssl1.1

            # FIX: Device creation failed: -19.
            # REF: https://github.com/microsoft/LightGBM/issues/586
RUN         mkdir -p /etc/OpenCL/vendors && \
            echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

COPY        --from=ffmpeg /usr/local /usr/local