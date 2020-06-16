#ARG BASE_IMAGE=ubuntu:18.04
ARG BASE_IMAGE=ubuntu:20.04
#ARG BASE_IMAGE=ubuntu:19.10
#ARG BASE_IMAGE=debian:10-slim
#ARG BASE_IMAGE=debian:9-slim

# should be set if run without buildx (buildkit)
ARG TARGETARCH=amd64


FROM $BASE_IMAGE as base

# Common build-time parameters set there
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TOOLCHAIN=stable
ARG OPENSSL_VERSION=1.1.1g
ARG POSTGRESQL_VERSION=11.8
ARG RUSTUSERID=100001

FROM base AS base-amd64
# Platform-depended parameters set there
ENV TARGET_CMAKE_C_FLAGS "-Wa,-mrelax-relocations=no"
ENV RUST_TARGET=x86_64-unknown-linux-musl

FROM base AS base-arm64
ENV TARGET_CMAKE_C_FLAGS ""
ENV RUST_TARGET=aarch64-unknown-linux-musl

FROM base AS base-arm
ENV TARGET_CMAKE_C_FLAGS ""
ENV RUST_TARGET=armv7-unknown-linux-musleabihf


FROM base-$TARGETARCH AS test3final
RUN env
RUN echo "Hello, my CPU architecture is $(uname -m)"
RUN echo TARGETPLATFORM: $TARGETPLATFORM TARGETARCH: $TARGETARCH BUILDPLATFORM: $BUILDPLATFORM


ENV DEBIAN_FRONTEND=noninteractive

RUN   apt-get update && apt-get upgrade -y && \
      apt-get install -y \
	ca-certificates \
        #cmake \
        curl \
        #file mc \
        sudo

WORKDIR /tmp

#RUN curl -fLO "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz"
#https://github.com/sudo-project/sudo/issues/42
#echo "Set disable_coredump false" >> /etc/sudo.conf

# test for sudo
RUN useradd rust --user-group --create-home --shell /bin/bash --groups sudo ${RUSTUSERID:+"-u $RUSTUSERID"}
# Allow sudo without a password.
RUN echo "rust   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/rust
RUN mkdir /app
USER rust
RUN sudo chown -R rust:rust /app

RUN curl -fLO "https://ftp.postgresql.org/pub/source/v$POSTGRESQL_VERSION/postgresql-$POSTGRESQL_VERSION.tar.gz"
ENV PATH=/home/rust/.cargo/bin:/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain $TOOLCHAIN && \
	  rustup target add $RUST_TARGET


