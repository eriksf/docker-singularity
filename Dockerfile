#FROM alpine:3.6
#RUN apk add --update alpine-sdk python linux-headers bash libarchive-dev e2fsprogs tar gzip grep squashfs-tools coreutils \
#    && apk cache clean

FROM ubuntu:xenial
RUN apt-get update \
    && apt-get install -y build-essential libarchive-dev wget python-dev squashfs-tools \
    && apt-get clean

ARG VERSION=2.3.2

RUN wget https://github.com/singularityware/singularity/releases/download/$VERSION/singularity-$VERSION.tar.gz \
    && tar -xzf singularity-$VERSION.tar.gz \
    && cd singularity-$VERSION \
    && ./configure --prefix=/ \
    && make -j2 && make install \
    && cd .. && rm -rf singularity*

ADD https://raw.githubusercontent.com/singularityware/docker2singularity/master/docker2singularity.sh /bin/docker2singularity.sh
RUN chmod a+x /bin/docker2singularity.sh

RUN /bin/singularity --version
