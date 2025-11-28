ARG SCHEME=chibi
ARG IMAGE=${SCHEME}:head
FROM debian:trixie AS build
RUN apt-get update && apt-get install -y \
git ca-certificates make gcc libffi-dev libffi-dev wget xz-utils
RUN mkdir ${HOME}/.snow && echo "()" > ${HOME}/.snow/config.scm
WORKDIR /build
RUN wget https://gitlab.com/-/project/6808260/uploads/094ce726ce3c6cf8c14560f1e31aaea0/akku-1.1.0.amd64-linux.tar.xz \
    && tar -xf akku-1.1.0.amd64-linux.tar.xz \
    && mv akku-1.1.0.amd64-linux akku
RUN git clone https://github.com/ashinn/chibi-scheme.git --depth=1
RUN git clone https://codeberg.org/retropikzel/compile-scheme.git --depth=1
RUN git clone https://codeberg.org/foreign-c/foreign-c.git --depth=1
WORKDIR /build/chibi-scheme
RUN make
RUN make install
WORKDIR /build/compile-scheme
RUN make build-gauche
WORKDIR /build
RUN akku install chez-srfi akku-r7rs "(foreign c)"

ARG SCHEME=chibi
ARG IMAGE=${SCHEME}:head
FROM schemers/${IMAGE}
RUN apt-get update && apt-get install -y make gcc libffi-dev libcurl4 gauche
RUN mkdir ${HOME}/.snow && echo "()" > ${HOME}/.snow/config.scm
COPY --from=build /build /build
ARG SCHEME=chibi
WORKDIR /build/compile-scheme
RUN make install
WORKDIR /build/chibi-scheme
RUN make install
WORKDIR /build/chibi-scheme
RUN make install
WORKDIR /build/akku
RUN bash install.sh
ENV PATH=/root/.local/bin:${PATH}
RUN akku update
WORKDIR /
RUN snow-chibi install --impls=${SCHEME} --always-yes "(srfi 64)"
RUN snow-chibi install --impls=${SCHEME} --always-yes "(foreign c)"
WORKDIR /workdir
COPY Makefile .
COPY retropikzel retropikzel/
COPY /build/.akku .akku

