#FROM alpine:3.6
#RUN apk add --update alpine-sdk python linux-headers bash libarchive-dev e2fsprogs tar gzip grep squashfs-tools coreutils \
#    && apk cache clean

FROM ubuntu:xenial

ARG VERSION=2.3.2

ADD scripts/verlte /bin/verlte
RUN chmod a+x /bin/verlte

RUN apt-get update \
    && apt-get install -y build-essential curl squashfs-tools \
    && apt-get clean

RUN apt-get update \
    && if verlte ${VERSION} 2.99; then \
        apt-get install -y libarchive-dev squashfs-tools python-dev; \
    else \
        cd /opt && curl -L https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz | tar -xz \
        && apt-get install -y libssl-dev uuid-dev libgpgme11-dev libseccomp-dev pkg-config git cryptsetup-bin; \
    fi \
    && apt-get clean

ENV GOROOT /opt/go
ENV PATH $GOROOT/bin:$PATH

RUN V=$(verlte ${VERSION} 2.99 && echo $VERSION || echo v${VERSION}) \
    && curl -L https://github.com/singularityware/singularity/releases/download/${V}/singularity-$VERSION.tar.gz | tar -xz \
    && cd $(verlte ${VERSION} 2.99 && echo singularity-${VERSION} || echo singularity) \
    && if verlte ${VERSION} 2.99; then \
        ./configure --prefix=/ \
        && make -j2 && make install; \
    else \
        ./mconfig && make -C ./builddir \
        && make -C ./builddir install; \
    fi \
    && cd .. && rm -rf singularity*

ADD https://raw.githubusercontent.com/singularityware/docker2singularity/master/docker2singularity.sh /bin/docker2singularity.sh
RUN chmod a+x /bin/docker2singularity.sh

RUN which singularity && singularity --version
