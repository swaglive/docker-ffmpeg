# TODO: Make external dependencies into its own build stage for build speed
FROM        ubuntu:20.04 AS base

WORKDIR     /tmp/workdir

RUN     apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ca-certificates && \
        apt-get autoremove -y && \
        apt-get clean -y

FROM        base AS build

ENV         DEBIAN_FRONTEND=noninteractive

ARG         MAKEFLAGS="-j4"
ARG         PKG_CONFIG_PATH="/opt/ffmpeg/share/pkgconfig:/opt/ffmpeg/lib/pkgconfig:/opt/ffmpeg/lib64/pkgconfig"
ARG         PREFIX=/opt/ffmpeg
ARG         LD_LIBRARY_PATH="/opt/ffmpeg/lib:/opt/ffmpeg/lib64"

WORKDIR     /tmp/workdir

RUN     apt-get -y update && \
        apt-get install --no-install-recommends -y \
            autoconf \
            automake \
            cmake \
            curl \
            bzip2 \
            g++ \
            gcc \
            git \
            libtool \
            make \
            nasm \
            perl \
            pkg-config \
            python \
            libssl-dev \
            yasm \
            zlib1g-dev

### fdk-aac https://github.com/mstorsjo/fdk-aac
ENV     FDKAAC_VERSION=0.1.5
RUN     DIR=/tmp/fdk-aac && mkdir -p ${DIR} && cd ${DIR} && \
        curl -sL https://github.com/mstorsjo/fdk-aac/archive/v${FDKAAC_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        autoreconf -fiv && \
        ./configure --prefix="${PREFIX}" --enable-shared --datadir="${DIR}" && \
        make && \
        make install && \
        rm -rf ${DIR}

## openjpeg https://github.com/uclouvain/openjpeg
ENV     OPENJPEG_VERSION=2.1.2
RUN     DIR=/tmp/openjpeg && mkdir -p ${DIR} && cd ${DIR} && \
        curl -sL https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        cmake -DBUILD_THIRDPARTY:BOOL=ON -DCMAKE_INSTALL_PREFIX="${PREFIX}" . && \
        make && \
        make install && \
        rm -rf ${DIR}

## x264 http://www.videolan.org/developers/x264.html
ENV     X264_VERSION=20170226-2245-stable
RUN     DIR=/tmp/x264 && mkdir -p ${DIR} && cd ${DIR} && \
        curl -sL https://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-${X264_VERSION}.tar.bz2 | \
        tar -jx --strip-components=1 && \
        ./configure --prefix="${PREFIX}" --enable-shared --enable-pic --disable-cli && \
        make && \
        make install && \
        rm -rf ${DIR}

### libwebp https://developers.google.com/speed/webp/
ENV     WEBP_VERSION=1.0.2
RUN     DIR=/tmp/webp && mkdir -p ${DIR} && cd ${DIR} && \
        curl -sL https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        ./configure --prefix="${PREFIX}" --enable-shared  && \
        make && \
        make install && \
        rm -rf ${DIR}

## libpng
ENV     LIBPNG_VERSION=1.6.9
RUN     DIR=/tmp/png && mkdir -p ${DIR} && cd ${DIR} && \
        git clone https://git.code.sf.net/p/libpng/code ${DIR} -b v${LIBPNG_VERSION} --depth 1 && \
        ./autogen.sh && \
        ./configure --prefix="${PREFIX}" && \
        make check && \
        make install && \
        rm -rf ${DIR}

## Download ffmpeg https://ffmpeg.org/
ENV     FFMPEG_VERSION=4.4.1
RUN     DIR=/tmp/ffmpeg && mkdir -p ${DIR} && cd ${DIR} && \
        curl -sLO https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 && \
        tar -jx --strip-components=1 -f ffmpeg-${FFMPEG_VERSION}.tar.bz2 && \
        ./configure \
            --disable-debug \
            --disable-doc \
            --disable-ffmpeg \
            --disable-ffplay \
            --disable-encoders \
            --disable-muxers \
            --disable-filters \
            --disable-hwaccels \
            --disable-decoders \
            --enable-decoder=png \
            --enable-decoder=jpeg2000 \
            --enable-decoder=jpegls \
            --enable-decoder=webp \
            --enable-decoder=mpeg1video \
            --enable-decoder=mpeg2video \
            --enable-decoder=mpeg4 \
            --enable-decoder=yuv4 \
            --enable-decoder=h264 \
            --enable-decoder=aac \
            --enable-decoder=webvtt \
            --enable-libx264 \
            --enable-libwebp \
            --enable-libopenjpeg \
            --enable-small \
            --enable-gpl \
            --enable-nonfree \
            --extra-libs=-ldl \
            --extra-libs=-lpthread \
            --extra-cflags="-I${PREFIX}/include" \
            --extra-ldflags="-L${PREFIX}/lib" \
            --prefix=${PREFIX} && \
        make && \
        make install

# ## cleanup
RUN \
        ldd ${PREFIX}/bin/ffprobe | grep opt/ffmpeg | cut -d ' ' -f 3 | xargs -i cp {} /usr/local/lib/ && \
        for lib in /usr/local/lib/*.so.*; do ln -s "${lib##*/}" "${lib%%.so.*}".so; done && \
        cp ${PREFIX}/bin/* /usr/local/bin/ && \
        cp -r ${PREFIX}/share/ffmpeg /usr/local/share/ && \
        LD_LIBRARY_PATH=/usr/local/lib ffprobe -buildconf && \
        cp -r ${PREFIX}/include/libav* ${PREFIX}/include/libpostproc ${PREFIX}/include/libsw* /usr/local/include && \
        mkdir -p /usr/local/lib/pkgconfig && \
        for pc in ${PREFIX}/lib/pkgconfig/libav*.pc ${PREFIX}/lib/pkgconfig/libpostproc.pc ${PREFIX}/lib/pkgconfig/libsw*.pc; do \
          sed "s:${PREFIX}:/usr/local:g" <"$pc" >/usr/local/lib/pkgconfig/"${pc##*/}"; \
        done

FROM    base AS release

ENV     LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64

COPY    --from=build /usr/local /usr/local/
