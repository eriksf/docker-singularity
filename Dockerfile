#FROM alpine:3.6
#RUN apk add --update alpine-sdk python linux-headers bash libarchive-dev e2fsprogs tar gzip grep squashfs-tools coreutils \
#    && apk cache clean

FROM ubuntu:xenial
RUN apt-get install -y build-essential libarchive-dev

ARG VERSION=2.3.2

RUN wget https://github.com/singularityware/singularity/releases/download/$VERSION/singularity-$VERSION.tar.gz \
    && tar -xzf singularity-$VERSION.tar.gz \
    && cd singularity-$VERSION \
    && ./configure --prefix=/ \
    && make -j2 && sudo make install \
    && cd .. && rm -rf singularity*

RUN /bin/singularity --version
